require 'minitest/autorun'
require_relative '../../lib/tigerbeetle/ruby/types/uint'

class TestUInt < Minitest::Test
  def setup
    @uint_classes = [UInt16, UInt32, UInt64, UInt128]
  end

  def test_init
    @uint_classes.each do |uint_cls|
      [0, (1 << uint_cls.n_bits) - 1].each do |value|
        u = uint_cls.new(value)
        assert_equal value, u.to_int
        assert_equal value.to_s, u.to_s
        assert_equal value.to_s(16).rjust(uint_cls.n_bytes * 2, '0'), u.to_hex

        assert_raises(TypeError) { uint_cls.new("a") }
        assert_raises(ValueError) { uint_cls.new(-1) }
        assert_raises(ValueError) { uint_cls.new(1 << uint_cls.n_bits) }
      end
    end
  end

  def test_operators
    @uint_classes.each do |uint_cls|
      v = (1 << uint_cls.n_bits) / 2 - 1
      u = uint_cls.new(v)

      assert_equal u, u
      assert_equal u, v
      assert_equal u, uint_cls.new(v)
      assert_equal u, uint_cls.from_bytes(u.to_bytes)
      refute_equal u, v - 1
      refute_equal u, uint_cls.new(v - 1)

      assert_operator u, :<, v + 1
      assert_operator u, :<, uint_cls.new(v + 1)
      assert_operator u, :<=, v
      assert_operator u, :<=, v + 1
      assert_operator u, :<=, uint_cls.new(v)
      assert_operator u, :<=, uint_cls.new(v + 1)
      assert_operator u, :>, v - 1
      assert_operator u, :>, uint_cls.new(v - 1)
      assert_operator u, :>=, v
      assert_operator u, :>=, v - 1
      assert_operator u, :>=, uint_cls.new(v)
      assert_operator u, :>=, uint_cls.new(v - 1)

      assert_equal u + 1, v + 1
      assert_equal u + 1, uint_cls.new(v + 1)
      assert_equal u - 1, v - 1
      assert_equal u - 1, uint_cls.new(v - 1)
      assert_equal u * 2, v * 2
      assert_equal u * 2, uint_cls.new(v * 2)
      assert_equal u.divmod(2)[0], v / 2
      assert_equal u.divmod(2)[0], uint_cls.new(v / 2)
      assert_equal u.divmod(2)[1], v % 2
      assert_equal u.divmod(2)[1], uint_cls.new(v % 2)
      assert_equal u << 1, v << 1
      assert_equal u << 1, uint_cls.new(v << 1)
      assert_equal u >> 1, v >> 1
      assert_equal u >> 1, uint_cls.new(v >> 1)
      assert_equal u & 1, v & 1
      assert_equal u & 1, uint_cls.new(v & 1)
      assert_equal u | 1, v | 1
      assert_equal u | 1, uint_cls.new(v | 1)
      assert_equal u ^ 1, v ^ 1
      assert_equal u ^ 1, uint_cls.new(v ^ 1)

      # illegal operations
      assert_raises(TypeError) { v / [] }
    end
  end

  def test_from_bytes
    @uint_classes.each do |uint_cls|
      v = (1 << uint_cls.n_bits) - 1
      u = uint_cls.from_bytes(v.to_s(16).rjust(uint_cls.n_bytes * 2, '0').scan(/../).reverse.map(&:hex).pack('C*'))

      assert_equal v, u.to_int

      assert_raises(ValueError) { uint_cls.from_bytes("\x00" * (uint_cls.n_bytes - 1)) }
      assert_raises(ValueError) { uint_cls.from_bytes("\x00" * (uint_cls.n_bytes + 1)) }
    end
  end

  def test_from_tuple
    @uint_classes.each do |uint_cls|
      v = (1 << uint_cls.n_bits) - 1
      u = uint_cls.from_tuple(
        v >> (uint_cls.n_bits / 2),
        v & ((1 << (uint_cls.n_bits / 2)) - 1)
      )

      assert_equal v, u.to_int

      assert_raises(ValueError) { uint_cls.from_tuple(0, -1) }
      assert_raises(ValueError) { uint_cls.from_tuple(1 << uint_cls.n_bits, 0) }
    end
  end
end