
require 'thread'
require 'securerandom'
require 'ffi'
require 'set'



class Request
    attr_accessor :id, :packet, :result, :ready
  
    def initialize(id, packet, result)
      @id = id
      @packet = packet
      @result = result
      @ready = Thread::Event.new
    end
end

def handle_exception(exception_class, exception_value, traceback)
    # Handle exceptions raised in the Zig client thread.
  
    # See the following link for why exceptions cannot be propagated there and have to be re-raised here:
    # https://cffi.readthedocs.io/en/latest/using.html#extern-python-reference
  
    raise exception_value, exception_value.message, traceback
end


def on_completion_fn(context, client, packet, result_ptr, result_len)
    # Simple statically registered extern "Python" fn. This gets
    # called for any callbacks, looks up the respective client from our
    # global mapping, and forwards on the callback.
  
    # NB: This runs in the Zig client thread.
    _on_completion_fn(context, client, packet, result_ptr, result_len)
  end
  
  def _on_completion_fn(context, client, packet, result_ptr, result_len)
    req = Client.inflight[ffi.cast("int", packet[0].user_data).to_i]
    raise "Packet mismatch" if req.packet != packet
  
    if result_len > 0 && !result_ptr.nil?
      op = Types::Enums::Operations.new(packet.operation.to_i)
      result_size = get_result_size(op)
      raise "Invalid result length" if result_len % result_size != 0
  
      if op != lib::TB_OPERATION_GET_ACCOUNT_TRANSFERS && op != lib::TB_OPERATION_GET_ACCOUNT_BALANCES
        # Make sure the amount of results at least matches the amount of requests.
        count = packet.data_size / get_event_size(op)
        raise "Invalid result length" if count * result_size < result_len
      end
    end
  
    req.result = result_ptr
    req.packet.data_size = result_len
    req.ready.set
end

def get_event_size(op)
    {
      lib::TB_OPERATION_CREATE_ACCOUNTS => ffi.sizeof("tb_account_t"),
      lib::TB_OPERATION_CREATE_TRANSFERS => ffi.sizeof("tb_transfer_t"),
      lib::TB_OPERATION_LOOKUP_ACCOUNTS => ffi.sizeof("tb_uint128_t"),
      lib::TB_OPERATION_LOOKUP_TRANSFERS => ffi.sizeof("tb_uint128_t"),
      lib::TB_OPERATION_GET_ACCOUNT_TRANSFERS => ffi.sizeof("tb_account_filter_t"),
      lib::TB_OPERATION_GET_ACCOUNT_BALANCES => ffi.sizeof("tb_account_filter_t")
    }[op] || 0
end
  
def get_result_size(op)
    {
      lib::TB_OPERATION_CREATE_ACCOUNTS => ffi.sizeof("tb_create_accounts_result_t"),
      lib::TB_OPERATION_CREATE_TRANSFERS => ffi.sizeof("tb_create_transfers_result_t"),
      lib::TB_OPERATION_LOOKUP_ACCOUNTS => ffi.sizeof("tb_account_t"),
      lib::TB_OPERATION_LOOKUP_TRANSFERS => ffi.sizeof("tb_transfer_t"),
      lib::TB_OPERATION_GET_ACCOUNT_TRANSFERS => ffi.sizeof("tb_account_t"),
      lib::TB_OPERATION_GET_ACCOUNT_BALANCES => ffi.sizeof("tb_account_balance_t")
    }[op] || 0
end
  
def request_ctx(c, packet = nil)
    packet ||= ffi.new("tb_packet_t *")
  
    status = lib.tb_client_acquire_packet(c[0], ffi.new("tb_packet_t * *", packet))
    raise errors::ConcurrencyExceededError if status == lib::TB_STATUS_CONCURRENCY_MAX_INVALID
    raise errors::ClientClosedError if status == lib::TB_PACKET_ACQUIRE_SHUTDOWN
    raise errors::TigerBeetleError, "Unexpected None packet" if packet.nil?
  
    req = Request.new(
      id: SecureRandom.uuid.to_i & 0x7FFFFFFF,
      packet: packet,
      result: nil,
      ready: Concurrent::Event.new
    )
  
    begin
      Client.inflight[req.id] = req
      yield req
    ensure
      lib.tb_client_release_packet(c[0], packet)
      Client.inflight.delete(req.id)
    end
end

def cint128_to_int(x)
  return UInt128.new(x.high,x.low).from_tuple
end

class Client
    # Client for TigerBeetle.
    
    @inflight = {}
  
    def initialize(cluster_id, addresses, concurrency_max)
      @tb_client = FFI::MemoryPointer.new(:pointer)
      addresses_raw = addresses.join(",").encode("UTF-8")
      status = lib.tb_client_init(
        @tb_client,
        cluster_id.tuple,
        FFI::MemoryPointer.from_string(addresses_raw),
        addresses_raw.size,
        concurrency_max,
        0,
        lib.method(:on_completion_fn)
      )
  
      if status != lib::TB_STATUS_SUCCESS
        self.class._raise_status(status)
      end
    end
  
    def self._raise_status(status)
      case status
      when lib::TB_STATUS_UNEXPECTED
        raise Errors::UnexpectedError
      when lib::TB_STATUS_OUT_OF_MEMORY
        raise Errors::OutOfMemoryError
      when lib::TB_STATUS_ADDRESS_INVALID
        raise Errors::InvalidAddressError
      when lib::TB_STATUS_ADDRESS_LIMIT_EXCEEDED
        raise Errors::AddressLimitExceededError
      when lib::TB_STATUS_CONCURRENCY_MAX_INVALID
        raise Errors::InvalidConcurrencyMaxError
      when lib::TB_STATUS_SYSTEM_RESOURCES
        raise Errors::SystemResourcesError
      when lib::TB_STATUS_NETWORK_SUBSYSTEM
        raise Errors::NetworkSubsystemError
      else
        msg = "Unexpected status: #{status}"
        raise Errors::TigerBeetleError, msg
      end
    end
  
    def _do_request(op, count, data, result_type)
      raise Errors::EmptyBatchError if count == 0
      raise Errors::ClientClosedError if @tb_client.null?
  
      req = RequestCtx.new(@tb_client)
      req.packet[:user_data] = req.id
      req.packet[:operation] = op.value
      req.packet[:status] = lib::TB_PACKET_OK
      req.packet[:data_size] = count * get_event_size(op)
      req.packet[:data] = data
  
      self.class.instance_variable_get(:@inflight)[req.id] = req
  
      # Submit the request.
      lib.tb_client_submit(@tb_client.read_pointer, req.packet)
  
      # Wait for the response
      req.ready.wait
  
      status = req.packet[:status].to_i
      if status != lib::TB_PACKET_OK
        case status
        when lib::TB_PACKET_TOO_MUCH_DATA
          raise Errors::MaximumBatchSizeExceededError
        when lib::TB_PACKET_INVALID_OPERATION
          raise Errors::InvalidOperationError
        when lib::TB_PACKET_INVALID_DATA_SIZE
          raise "unreachable"
        else
          raise "tb_client_submit(): returned packet with invalid status"
        end
      end
  
      result_count = req.packet[:data_size] / get_result_size(op)
      FFI::MemoryPointer.new(result_type, result_count).read_array_of_type(result_type, :read_pointer, result_count)
    end
  
    def close
      unless @tb_client.null?
        lib.tb_client_deinit(@tb_client.read_pointer)
        @tb_client = nil
      end
    end

    def create_accounts(accounts)
      # Create accounts in the ledger.
  
      count = accounts.size
  
      batch = FFI::MemoryPointer.new(:tb_account_t, count)
      accounts.each_with_index do |account, idx|
        batch[idx][:id] = account.id.tuple
        batch[idx][:ledger] = account.ledger.int
        batch[idx][:code] = account.code.int
        batch[idx][:flags] = account.flags.int
        batch[idx][:user_data_128] = account.user_data_128.tuple
        batch[idx][:user_data_64] = account.user_data_64.int
        batch[idx][:user_data_32] = account.user_data_32.int
        batch[idx][:timestamp] = 0
      end
  
      results = _do_request(
        Types::Enums::Operations::CREATE_ACCOUNTS,
        count,
        batch,
        :tb_create_accounts_result_t
      )
      results_by_idx = results.each_with_object({}) { |result, h| h[result[:index]] = result }
  
      (0...count).map do |idx|
        if results_by_idx.key?(idx)
          TigerBeetle::CreateAccountsResult.new(
            results_by_idx[idx][:index],
            Types::Enums::CreateAccountsResult.new(results_by_idx[idx][:result])
          )
        else
          TigerBeetle::CreateAccountsResult.new(
            idx,
            Types::Enums::CreateAccountsResult.new(Types::Enums::CreateAccountsResult::OK)
          )
        end
      end
    end

    def create_transfers(transfers)
      # Create transfers in the ledger.
  
      count = transfers.size
  
      batch = FFI::MemoryPointer.new(:tb_transfer_t, count)
      transfers.each_with_index do |transfer, idx|
        batch[idx][:id] = transfer.id.tuple
        batch[idx][:debit_account_id] = transfer.debit_account_id.tuple
        batch[idx][:credit_account_id] = transfer.credit_account_id.tuple
        batch[idx][:amount] = transfer.amount.tuple
        batch[idx][:pending_id] = transfer.pending_id.tuple
        batch[idx][:user_data_128] = transfer.user_data_128.tuple
        batch[idx][:user_data_64] = transfer.user_data_64.int
        batch[idx][:user_data_32] = transfer.user_data_32.int
        batch[idx][:timeout] = transfer.timeout.int
        batch[idx][:ledger] = transfer.ledger.int
        batch[idx][:code] = transfer.code.int
        batch[idx][:flags] = transfer.flags.int
        batch[idx][:timestamp] = 0
      end
  
      results = _do_request(
        Types::Enums::Operations::CREATE_TRANSFERS,
        count,
        batch,
        :tb_create_transfers_result_t
      )
      results_by_idx = results.each_with_object({}) { |result, h| h[result[:index]] = result }
  
      (0...count).map do |idx|
        if results_by_idx.key?(idx)
          TigerBeetle::CreateTransfersResult.new(
            results_by_idx[idx][:index],
            Types::Enums::CreateTransferResult.new(results_by_idx[idx][:result])
          )
        else
          TigerBeetle::CreateTransfersResult.new(
            idx,
            Types::Enums::CreateTransferResult.new(Types::Enums::CreateTransferResult::OK)
          )
        end
      end
    end

    def lookup_accounts(account_ids)
        # Lookup accounts in the ledger.
    
        count = account_ids.size
        batch = FFI::MemoryPointer.new(:tb_uint128_t, count)
        account_ids.each_with_index { |id, idx| batch[idx] = id.tuple }
    
        results = _do_request(
          Types::Enums::Operations::LOOKUP_ACCOUNTS,
          count,
          batch,
          :tb_account_t
        )
    
        results.map do |result|
          TigerBeetle::Account.new(
            id: cint128_to_int(result[:id]),
            debits_pending: cint128_to_int(result[:debits_pending]),
            debits_posted: cint128_to_int(result[:debits_posted]),
            credits_pending: cint128_to_int(result[:credits_pending]),
            credits_posted: cint128_to_int(result[:credits_posted]),
            user_data_128: cint128_to_int(result[:user_data_128]),
            user_data_64: UInt64.new(result[:user_data_64]),
            user_data_32: UInt32.new(result[:user_data_32]),
            ledger: UInt32.new(result[:ledger]),
            code: UInt16.new(result[:code]),
            flags: UInt16.new(result[:flags]),
            timestamp: UInt64.new(result[:timestamp]),
            reserved: result[:reserved]
          )
        end
    end
    
    def lookup_transfers(transfer_ids)
        # Lookup transfers in the ledger.

        count = transfer_ids.size
        batch = FFI::MemoryPointer.new(:tb_uint128_t, count)
        transfer_ids.each_with_index { |id, idx| batch[idx] = id.tuple }

        results = _do_request(
            Types::Enums::Operations::LOOKUP_TRANSFERS,
            count,
            batch,
            :tb_transfer_t
        )

        results.map do |result|
          TigerBeetle::Transfer.new(
            id: cint128_to_int(result[:id]),
            debit_account_id: cint128_to_int(result[:debit_account_id]),
            credit_account_id: cint128_to_int(result[:credit_account_id]),
            amount: cint128_to_int(result[:amount]),
            pending_id: cint128_to_int(result[:pending_id]),
            user_data_128: cint128_to_int(result[:user_data_128]),
            user_data_64: UInt64.new(result[:user_data_64]),
            user_data_32: UInt32.new(result[:user_data_32]),
            timeout: UInt32.new(result[:timeout]),
            ledger: UInt32.new(result[:ledger]),
            code: UInt16.new(result[:code]),
            flags: UInt16.new(result[:flags]),
            timestamp: UInt64.new(result[:timestamp])
            )
        end
    end

    def get_account_balances(filt)
        # Get balances for an account.
    
        batch = FFI::MemoryPointer.new(:tb_account_filter_t, 1)
        batch[0][:account_id] = filt.account_id.tuple
        batch[0][:timestamp_min] = filt.timestamp_min.int
        batch[0][:timestamp_max] = filt.timestamp_max.int
        batch[0][:limit] = filt.limit.int
        batch[0][:flags] = filt.flags.int
    
        results = _do_request(
          Types::Enums::Operations::GET_ACCOUNT_BALANCES,
          1,
          batch,
          :tb_account_balance_t
        )
    
        results.map do |result|
          TigerBeetle::AccountBalance.new(
            debits_pending: cint128_to_int(result[:debits_pending]),
            debits_posted: cint128_to_int(result[:debits_posted]),
            credits_pending: cint128_to_int(result[:credits_pending]),
            credits_posted: cint128_to_int(result[:credits_posted]),
            timestamp: UInt64.new(result[:timestamp])
          )
        end
      end
    end