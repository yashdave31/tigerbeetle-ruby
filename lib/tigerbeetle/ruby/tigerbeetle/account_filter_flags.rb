module TigerBeetle
class AccountFilterFlags
    attr_reader :debits, :credits, :reversed
  
    def initialize(debits: true, credits: true, reversed: false)
      @debits = debits
      @credits = credits
      @reversed = reversed
    end
  
    def to_uint32
      value = 0
      value |= (@debits ? 1 : 0) << 0
      value |= (@credits ? 1 : 0) << 1
      value |= (@reversed ? 1 : 0) << 2
      UInt32.new(value)
    end
end
end