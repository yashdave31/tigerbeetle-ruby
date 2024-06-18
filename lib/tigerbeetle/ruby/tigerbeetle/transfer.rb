module TigerBeetle
  class Transfer
    attr_reader :id, :debit_account_id, :credit_account_id, :amount, :ledger, :code, :pending_id, :user_data_128,
                :user_data_64, :user_data_32, :timeout, :flags, :timestamp
  
    def initialize(id, debit_account_id, credit_account_id, amount, ledger, code, pending_id: UInt128.new(0),
                   user_data_128: UInt128.new(0), user_data_64: UInt64.new(0), user_data_32: UInt32.new(0),
                   timeout: UInt32.new(0), flags: TransferFlags.new.to_uint16, timestamp: UInt64.new(0))
      @id = id
      @debit_account_id = debit_account_id
      @credit_account_id = credit_account_id
      @amount = amount
      @ledger = ledger
      @code = code
      @pending_id = pending_id
      @user_data_128 = user_data_128
      @user_data_64 = user_data_64
      @user_data_32 = user_data_32
      @timeout = timeout
      @flags = flags
      @timestamp = timestamp
    end
  
    def get_flags
      TransferFlags.new(
        linked: (@flags.to_s.to_i & 1) != 0,
        pending: (@flags.to_s.to_i & 2) != 0,
        post_pending_transfer: (@flags.to_s.to_i & 4) != 0,
        void_pending_transfer: (@flags.to_s.to_i & 8) != 0,
        balancing_debit: (@flags.to_s.to_i & 16) != 0,
        balancing_credit: (@flags.to_s.to_i & 32) != 0
      )
    end
end
end
