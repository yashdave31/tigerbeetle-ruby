require 'ruby-enum'

module Types
  module Enums
    class CreateAccountResult
      include Ruby::Enum
    
      define :OK, 0
      define :LINKED_EVENT_FAILED, 1
      define :LINKED_EVENT_CHAIN_OPEN, 2
      define :TIMESTAMP_MUST_BE_ZERO, 3
      define :RESERVED_FIELD, 4
      define :RESERVED_FLAG, 5
      define :ID_MUST_NOT_BE_ZERO, 6
      define :ID_MUST_NOT_BE_INT_MAX, 7
      define :FLAGS_ARE_MUTUALLY_EXCLUSIVE, 8
      define :DEBITS_PENDING_MUST_BE_ZERO, 9
      define :DEBITS_POSTED_MUST_BE_ZERO, 10
      define :CREDITS_PENDING_MUST_BE_ZERO, 11
      define :CREDITS_POSTED_MUST_BE_ZERO, 12
      define :LEDGER_MUST_NOT_BE_ZERO, 13
      define :CODE_MUST_NOT_BE_ZERO, 14
      define :EXISTS_WITH_DIFFERENT_FLAGS, 15
      define :EXISTS_WITH_DIFFERENT_USER_DATA_128, 16
      define :EXISTS_WITH_DIFFERENT_USER_DATA_64, 17
      define :EXISTS_WITH_DIFFERENT_USER_DATA_32, 18
      define :EXISTS_WITH_DIFFERENT_LEDGER, 19
      define :EXISTS_WITH_DIFFERENT_CODE, 20
      define :EXISTS, 21
    end
  end
end
