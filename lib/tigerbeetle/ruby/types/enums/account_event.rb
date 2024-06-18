require 'ruby-enum'
module Types
  module Enums
    class AccountEvent
      include Ruby::Enum
    
      define :CREATE, 0
      define :TRANSFER, 1
    end
  end
end
