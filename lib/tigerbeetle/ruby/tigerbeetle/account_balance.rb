module TigerBeetle
    class AccountBalance
        attr_accessor :debits_pending, :debits_posted, :credits_pending, :credits_posted, :timestamp
    
        def initialize(debits_pending, debits_posted, credits_pending, credits_posted, timestamp)
            @debits_pending = debits_pending
            @debits_posted = debits_posted
            @credits_pending = credits_pending
            @credits_posted = credits_posted
            @timestamp = timestamp
        end
    end
end