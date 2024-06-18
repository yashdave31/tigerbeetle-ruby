
require 'securerandom'
require 'thread'

ID_LAST_TIMESTAMP = 0
ID_LAST_RANDOM = "\0" * 10
ID_MUTEX = Mutex.new

def ID()
    timestamp = (Time.now.to_f * 1000).to_i
  
    ID_MUTEX.synchronize do
      if timestamp <= ID_LAST_TIMESTAMP
        timestamp = ID_LAST_TIMESTAMP
      else
        timestamp = ID_LAST_TIMESTAMP
        begin
          timestamp = SecureRandom.bytes(10)
        rescue
          raise "SecureRandom failed to provide random bytes"
        end
      end
  
      id_last_random = ID_LAST_RANDOM.dup
  
      random_lo = id_last_random[0, 8].unpack1("Q<")
      random_hi = id_last_random[8, 2].unpack1("S<")
  
      random_lo += 1
      if random_lo == 2**64
        random_hi += 1
        if random_hi == 2**16
          raise "random bits overflow on monotonic increment"
        end
      end
  
      id_last_random = [random_lo].pack("Q<") + [random_hi].pack("S<")
  
      ulid = [random_lo].pack("Q<") + [random_hi].pack("S<") + [timestamp & 0xFFFF].pack("S<") + [(timestamp >> 16)].pack("L<")
      return UInt128.from_bytes(ulid)
    end
end