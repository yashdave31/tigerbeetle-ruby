module TigerBeetle
  class Account
      attr_reader :id, :ledger, :code, :debits_pending, :debits_posted, :credits_pending, :credits_posted,
                  :user_data_128, :user_data_64, :user_data_32, :flags, :timestamp, :reserved
    
      def initialize(id, ledger, code, debits_pending: UInt128.new(0), debits_posted: UInt128.new(0), credits_pending: UInt128.new(0),
                    credits_posted: UInt128.new(0), user_data_128: UInt128.new(0), user_data_64: UInt64.new(0),
                    user_data_32: UInt32.new(0), flags: AccountFlags.new.to_uint16, timestamp: UInt64.new(0), reserved: 0)
        @id = id
        @ledger = ledger
        @code = code
        @debits_pending = debits_pending
        @debits_posted = debits_posted
        @credits_pending = credits_pending
        @credits_posted = credits_posted
        @user_data_128 = user_data_128
        @user_data_64 = user_data_64
        @user_data_32 = user_data_32
        @flags = flags
        @timestamp = timestamp
        @reserved = reserved
      end
    
      def get_flags
        AccountFlags.new(
          linked: (@flags.to_s.to_i & 1) != 0,
          debits_must_not_exceed_credits: (@flags.to_s.to_i & 2) != 0,
          credits_must_not_exceed_debits: (@flags.to_s.to_i & 4) != 0,
          history: (@flags.to_s.to_i & 8) != 0
        )
      end
  end
end