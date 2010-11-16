require 'helper.rb'

class TestW800rf32Receiver < Test::Unit::TestCase

  def setup
    @generic_parser = GenericX10Parser.new
    @ds10_parser = Ds10aParser.new
    @kr10_parser = Kr10aParser.new
    @receiver = W800rf32Receiver.new(nil,
                                     :parsers => [@generic_parser, @ds10_parser, @kr10_parser])
  end


  test "correct parser accepts packet" do
    ds10_packet = [ 0b10110010, 0b01000010, 0b10100001, 0b01011110]
    assert_equal @ds10_parser, @receiver.accepting_parser(ds10_packet)

    kr10_packet = [ 0b10110010, 0b01000010, 0b01100000, 0b10011111]
    assert_equal @kr10_parser, @receiver.accepting_parser(kr10_packet)

    generic_packet = [ 0b00101111, 0b11010000, 0b00011111, 0b11100000]
    assert_equal @generic_parser, @receiver.accepting_parser(generic_packet)

  end


  test "hex conversion works" do
    assert_equal "0xaa ", @receiver.as_hex([170])
    assert_equal "0x10 0xaa ", @receiver.as_hex([16,170])
  end

  test "binary conversion works" do
    assert_equal "0b00110011 ", @receiver.as_binary([0x33])
    assert_equal "0b00110011 0b10010100 ", @receiver.as_binary([0x33,0x94])
  end

  test 'reverse byte works' do
    assert_equal 0b11001010, @receiver.reverse_byte(0b01010011)
    assert_equal 0b00110010, @receiver.reverse_byte(0b01001100)
    assert_not_equal 0b00110011, @receiver.reverse_byte(0b00110011)
  end

  test 'reverse bytes works' do
    assert_equal [0b11001100, 0b01100011], @receiver.reverse_bytes([0b00110011, 0b11000110])
    assert_equal [0b01110111, 0b10101010], @receiver.reverse_bytes([0b11101110, 0b01010101])
  end
end
