require 'ruby-enum'

class Operations
  include Ruby::Enum

  define :PULSE, 128
  define :CREATE_ACCOUNTS, 129
  define :CREATE_TRANSFERS, 130
  define :LOOKUP_ACCOUNTS, 131
  define :LOOKUP_TRANSFERS, 132
  define :GET_ACCOUNT_TRANSFERS, 133
  define :GET_ACCOUNT_BALANCES, 134
  
end
