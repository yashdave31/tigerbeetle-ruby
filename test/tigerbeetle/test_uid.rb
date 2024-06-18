require_relative '../test_helper'
require_relative '../../lib/tigerbeetle/ruby/types/uid'


class UID
  @@last_id = 0
  @@mutex = Mutex.new

  def self.generate
    @@mutex.synchronize do
      @@last_id += 1
    end
  end
end

def verifier
  id_a = UID.generate
  1_000.times do |i|
    sleep(1 * 1e-3) if i % 10 == 0
    id_b = UID.generate
    raise "ID is not monotonic" unless id_b > id_a
    id_a = id_b
  end
end

class TestUID < Minitest::Test
  def test_id_locally
    verifier
  end

  def test_id_threads
    concurrency = 10
    barrier = Barrier.new(concurrency)

    threads = Array.new(concurrency) do
      Thread.new do
        i = Thread.current.object_id
        puts "Thread #{i} started"
        barrier.wait
        puts "Thread #{i} running verifier"
        verifier
        puts "Thread #{i} finished"
      end
    end

    threads.each(&:join)
  end
end

class Barrier
  def initialize(count)
    @count = count
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @waiting = 0
  end

  def wait
    @mutex.synchronize do
      @waiting += 1
      if @waiting == @count
        @cond.broadcast
      else
        @cond.wait(@mutex)
      end
    end
  end
end