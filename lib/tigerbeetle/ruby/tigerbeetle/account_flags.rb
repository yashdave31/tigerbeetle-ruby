module TigerBeetle
  class AccountFlags
    attr_reader :linked, :debits_must_not_exceed_credits, :credits_must_not_exceed_debits, :history
  
    def initialize(linked: false, debits_must_not_exceed_credits: false, credits_must_not_exceed_debits: false, history: false)
      @linked = linked
      @debits_must_not_exceed_credits = debits_must_not_exceed_credits
      @credits_must_not_exceed_debits = credits_must_not_exceed_debits
      @history = history
    end
    
    def to_uint16
      # Calculate the UInt16 value based on the flags
      value = 0
      value |= (@linked ? 1 : 0) << 0
      value |= (@debits_must_not_exceed_credits ? 1 : 0) << 1
      value |= (@credits_must_not_exceed_debits ? 1 : 0) << 2
      value |= (@history ? 1 : 0) << 3      
      UInt16.new(value)
    end
end
end