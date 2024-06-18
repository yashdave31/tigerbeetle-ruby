require 'ruby-enum'

class AccountEvent
  include Ruby::Enum

  define :CREATE, 0
  define :TRANSFER, 1
end