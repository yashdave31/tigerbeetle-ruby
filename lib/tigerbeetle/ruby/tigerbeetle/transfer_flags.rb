module TigerBeetle
  class TransferFlags
    attr_reader :linked, :pending, :post_pending_transfer, :void_pending_transfer, :balancing_debit, :balancing_credit
  
    def initialize(linked: false, pending: false, post_pending_transfer: false, void_pending_transfer: false, balancing_debit: false, balancing_credit: false)
      @linked = linked
      @pending = pending
      @post_pending_transfer = post_pending_transfer
      @void_pending_transfer = void_pending_transfer
      @balancing_debit = balancing_debit
      @balancing_credit = balancing_credit
    end
  
    def to_uint16
      # Calculate the UInt16 value based on the flags
      value = 0
      value |= (@linked ? 1 : 0) << 0
      value |= (@pending ? 1 : 0) << 1
      value |= (@post_pending_transfer ? 1 : 0) << 2
      value |= (@void_pending_transfer ? 1 : 0) << 3
      value |= (@balancing_debit ? 1 : 0) << 4
      value |= (@balancing_credit ? 1 : 0) << 5
      
      UInt16.new(value)
    end
end  
end
