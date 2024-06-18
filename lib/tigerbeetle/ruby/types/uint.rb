class UInt
    attr_reader :memory, :n_bits
  
    def initialize(integer)
      raise TypeError, "integer must be an integer" unless integer.is_a?(Integer)
      raise ValueError, "integer must be non-negative" if integer < 0
      if integer.bit_length > self.class.n_bits
        raise ValueError, "integer must be less than 2**#{self.class.n_bits}"
      end
  
      @memory = self.class._int_to_bytes(integer, self.class.n_bytes)
    end
  
    def self._int_to_bytes(n, length)
      n.to_s(16).rjust(length * 2, '0').scan(/../).reverse.map(&:hex)
    end
  
    def self._bytes_to_int(b)
      b.reverse.map { |byte| byte.to_s(16).rjust(2, '0') }.join.to_i(16)
    end
  
    def hash
      @memory.hash
    end
  
    def to_bytes
      @memory.pack('C*')
    end
  
    def to_int
      self.class._bytes_to_int(@memory)
    end
  
    def to_f
      to_int.to_f
    end
  
    def to_index
      to_int
    end
  
    def inspect
      "#{self.class.name}(#{to_int})"
    end
  
    def to_s
      to_int.to_s
    end
  
    def +(other)
      case other
      when UInt
        self.class.new(to_int + other.to_int)
      when String
        self.class.new(to_int + other.to_i)
      when Integer
        self.class.new(to_int + other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def -(other)
      case other
      when UInt
        self.class.new(to_int - other.to_int)
      when String
        self.class.new(to_int - other.to_i)
      when Integer
        self.class.new(to_int - other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def *(other)
      case other
      when UInt
        self.class.new(to_int * other.to_int)
      when String
        self.class.new(to_int * other.to_i)
      when Integer
        self.class.new(to_int * other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def divmod(other)
      case other
      when UInt
        [self.class.new(to_int / other.to_int), self.class.new(to_int % other.to_int)]
      when String
        [self.class.new(to_int / other.to_i), self.class.new(to_int % other.to_i)]
      when Integer
        [self.class.new(to_int / other), self.class.new(to_int % other)]
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def /(other)
      case other
      when UInt
        self.class.new(to_int / other.to_int)
      when String
        self.class.new(to_int / other.to_i)
      when Integer
        self.class.new(to_int / other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def %(other)
      case other
      when UInt
        self.class.new(to_int % other.to_int)
      when String
        self.class.new(to_int % other.to_i)
      when Integer
        self.class.new(to_int % other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def **(other)
      case other
      when UInt
        self.class.new(to_int**other.to_int)
      when String
        self.class.new(to_int**other.to_i)
      when Integer
        self.class.new(to_int**other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def <<(other)
      case other
      when UInt
        self.class.new(to_int << other.to_int)
      when String
        self.class.new(to_int << other.to_i)
      when Integer
        self.class.new(to_int << other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def >>(other)
      case other
      when UInt
        self.class.new(to_int >> other.to_int)
      when String
        self.class.new(to_int >> other.to_i)
      when Integer
        self.class.new(to_int >> other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def &(other)
      case other
      when UInt
        self.class.new(to_int & other.to_int)
      when String
        self.class.new(to_int & other.to_i)
      when Integer
        self.class.new(to_int & other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def |(other)
      case other
      when UInt
        self.class.new(to_int | other.to_int)
      when String
        self.class.new(to_int | other.to_i)
      when Integer
        self.class.new(to_int | other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def ^(other)
      case other
      when UInt
        self.class.new(to_int ^ other.to_int)
      when String
        self.class.new(to_int ^ other.to_i)
      when Integer
        self.class.new(to_int ^ other)
      else
        raise TypeError, "Unsupported type"
      end
    end
  
    def ==(other)
      case other
      when UInt
        @memory == other.memory
      when String
        to_s == other
      when Integer
        to_int == other
      else
        false
      end
    end
  
    def !=(other)
      !self.==(other)
    end
  
    def <(other)
      case other
      when UInt
        to_int < other.to_int
      when String
        to_int < other.to_i
      when Integer
        to_int < other
      else
        false
      end
    end
  
    def >(other)
      case other
      when UInt
        to_int > other.to_int
      when String
        to_int > other.to_i
      when Integer
        to_int > other
      else
        false
      end
    end
  
    def <=(other)
      case other
      when UInt
        to_int <= other.to_int
      when String
        to_int <= other.to_i
      when Integer
        to_int <= other
      else
        false
      end
    end
  
    def >=(other)
      case other
      when UInt
        to_int >= other.to_int
      when String
        to_int >= other.to_i
      when Integer
        to_int >= other
      else
        false
      end
    end
  
    def to_tuple
      [high, low]
    end
  
    def to_bool
      !to_int.zero?
    end
  
    def high
      self.class._bytes_to_int(@memory[self.class.n_bytes / 2..-1])
    end
  
    def low
      self.class._bytes_to_int(@memory[0...self.class.n_bytes / 2])
    end
  
    def to_hex
      to_bytes.unpack1('H*')
    end
  
    def to_bin
      to_int.to_s(2).rjust(self.class.n_bits, '0')
    end
  
    def self.n_bytes
      self.n_bits / 8
    end
  
    def self.from_bytes(b)
      unless b.is_a?(String)
        raise TypeError, "b must be a String"
      end
  
      if b.length != self.n_bytes
        raise ValueError, "b must be #{self.n_bytes} bytes, got #{b.length}"
      end
  
      self.new(_bytes_to_int(b.bytes))
    end
  
    def self.from_tuple(high, low)
      raise TypeError, "high must be an integer" unless high.is_a?(Integer)
      raise TypeError, "low must be an integer" unless low.is_a?(Integer)
      raise ValueError, "high must be non-negative" if high < 0
      raise ValueError, "low must be non-negative" if low < 0
  
      if high.bit_length > self.n_bits / 2
        raise ValueError, "high must be less than 2**#{self.n_bits / 2}"
      end
  
      if low.bit_length > self.n_bits / 2
        raise ValueError, "low must be less than 2**#{self.n_bits / 2}"
      end
  
      self.new((high << (self.n_bits / 2)) | low)
    end
  end
  
  class UInt128 < UInt
    def self.n_bits
      128
    end
  end
  
  class UInt64 < UInt
    def self.n_bits
      64
    end
  end
  
  class UInt32 < UInt
    def self.n_bits
      32
    end
  end
  
  class UInt16 < UInt
    def self.n_bits
      16
    end
  end
  
  class TypeError < StandardError; end
  class ValueError < StandardError; end