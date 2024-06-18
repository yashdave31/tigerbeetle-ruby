require 'set'


class UInt
    attr_reader :memory, :n_bits
    def initialize(integer)
        raise TypeError.new("integer must be an integer") unless integer.is_a?(Integer)
        raise ValueError.new("integer must be non-negative") if integer < 0
        raise ValueError.new("integer must be less than 2**#{@n_bits}") if integer.bit_length > @n_bits
    
        @memory = integer.to_s(2).rjust(@n_bits, '0').scan(/.{8}/).map(&:to_i).pack('C*').b
    end

    def ==(other)
        if other.is_a?(UInt)
          @memory == other.memory
        elsif other.is_a?(String)
          @memory == other.to_i
        elsif other.is_a?(Integer)
          @memory == other
        else
          raise TypeError.new("Comparison not supported")
        end
    end

    def +(other)
        if other.is_a?(UInt)
          UInt.new(@memory + other.memory)
        elsif other.is_a?(String)
          UInt.new(@memory + other.to_i)
        elsif other.is_a?(Integer)
          UInt.new(@memory + other)
        else
          raise TypeError.new("Addition not supported")
        end
    end
    
    def -(other)
        if other.is_a?(UInt)
            UInt.new(@memory - other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory - other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory - other)
        else
            raise TypeError.new("Subtraction not supported")
        end
    end

    def *(other)
        if other.is_a?(UInt)
            UInt.new(@memory * other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory * other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory * other)
        else
            raise TypeError.new("Multiplication not supported")
        end
    end

    def divmod(other)
        if other.is_a?(UInt)
            [UInt.new(@memory / other.memory), UInt.new(@memory % other.memory)]
        elsif other.is_a?(String)
            [UInt.new(@memory / other.to_i), UInt.new(@memory % other.to_i)]
        elsif other.is_a?(Integer)
            [UInt.new(@memory / other), UInt.new(@memory % other)]
        else
            raise TypeError.new("Divmod operation not supported")
        end
    end

    def /(other)
        if other.is_a?(UInt)
            UInt.new(@memory / other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory / other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory / other)
        else
            raise TypeError.new("Division not supported")
        end
    end

    def %(other)
        if other.is_a?(UInt)
            UInt.new(@memory % other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory % other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory % other)
        else
            raise TypeError.new("Modulus operation not supported")
        end
    end

    def **(other)
        if other.is_a?(UInt)
            UInt.new(@memory ** other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory ** other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory ** other)
        else
            raise TypeError.new("Exponentiation not supported")
        end
    end

    def <<(other)
        if other.is_a?(UInt)
            UInt.new(@memory << other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory << other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory << other)
        else
            raise TypeError.new("Left shift operation not supported")
        end
    end

    def >>(other)
        if other.is_a?(UInt)
          UInt.new(@memory >> other.memory)
        elsif other.is_a?(String)
          UInt.new(@memory >> other.to_i)
        elsif other.is_a?(Integer)
          UInt.new(@memory >> other)
        else
          raise TypeError.new("Right shift operation not supported")
        end
    end
    
    def &(other)
        if other.is_a?(UInt)
            UInt.new(@memory & other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory & other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory & other)
        else
            raise TypeError.new("Bitwise AND operation not supported")
        end
    end
    
    def |(other)
        if other.is_a?(UInt)
            UInt.new(@memory | other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory | other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory | other)
        else
            raise TypeError.new("Bitwise OR operation not supported")
        end
    end
    
    def ^(other)
        if other.is_a?(UInt)
            UInt.new(@memory ^ other.memory)
        elsif other.is_a?(String)
            UInt.new(@memory ^ other.to_i)
        elsif other.is_a?(Integer)
            UInt.new(@memory ^ other)
        else
            raise TypeError.new("Bitwise XOR operation not supported")
        end
    end
    
    def <(other)
        if other.is_a?(UInt)
            @memory < other.memory
        elsif other.is_a?(String)
            @memory < other.to_i
        elsif other.is_a?(Integer)
            @memory < other
        else
            raise TypeError.new("Comparison not supported")
        end
    end
    
    def >(other)
        if other.is_a?(UInt)
            @memory > other.memory
        elsif other.is_a?(String)
            @memory > other.to_i
        elsif other.is_a?(Integer)
            @memory > other
        else
            raise TypeError.new("Comparison not supported")
        end
    end
    
    def <=(other)
        if other.is_a?(UInt)
            @memory <= other.memory
        elsif other.is_a?(String)
            @memory <= other.to_i
        elsif other.is_a?(Integer)
            @memory <= other
        else
            raise TypeError.new("Comparison not supported")
        end
    end
    
    def >=(other)
        if other.is_a?(UInt)
            @memory >= other.memory
        elsif other.is_a?(String)
            @memory >= other.to_i
        elsif other.is_a?(Integer)
            @memory >= other
        else
            raise TypeError.new("Comparison not supported")
        end
    end

    
end

class UInt16
    def initialize(value)
      @value = value
    end
  
    def to_s
      @value.to_s
    end
end
  
class UInt32
    def initialize(value)
        @value = value
    end

    def to_s
        @value.to_s
    end
end

class UInt64
    def initialize(value)
      @value = value
    end
  
    def to_s
      @value.to_s
    end
end
  
class UInt128
    def initialize(value)
        @value = value
    end

    def to_s
        @value.to_s
    end
end