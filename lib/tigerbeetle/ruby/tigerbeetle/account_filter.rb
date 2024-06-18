module TigerBeetle
    class AccountFilter
    attr_reader :debits, :credits, :reversed
  
    def initialize(account_id,timestamp_min: UInt64.new(0),timestamp_max: UInt64.new(0),limit: UInt32.new(8190),flags: AccountFilterFlags.new().to_uint32())
      @account_id = account_id
      @timestamp_min = timestamp_min
      @timestamp_max = timestamp_max
      @limit = limit
      @flags = flags
    end
  
    def get_flags
        AccountFilterFlags.new(
          debits: ((flags >> 0) & 0x1) == 1,
          credits: ((flags >> 1) & 0x1) == 1,
          reversed: ((flags >> 2) & 0x1) == 1
        )
    end
end
end