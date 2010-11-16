require 'helper.rb'
require "generic_x10_parser"

# tests the generic X10 parser
class TestGenericX10Parser < Test::Unit::TestCase

  def setup
    @ds10a = GenericX10Parser.new
  end

  # tests that valid packets are accepted
  test "valid packet" do
    ds10packets = [ { :raw_data => [ 0b00101111, 0b11010000, 0b00011111, 0b11100000],
                      :packet => {:device_type=>"X10", :house_code => 'J', :unit => 16, :state => 'OFF'}},
                    { :raw_data => [ 0b00001111, 0b11110000, 0b00011011, 0b11100100],
                      :packet => {:device_type=>"X10", :house_code => 'J', :unit => 8, :state => 'ON'}},
                    { :raw_data => [ 0b00001100, 0b11110011, 0b000010001, 0b11101110],
                      :packet => {:device_type=>"X10", :house_code => 'P', :dim => 'BRIGHT'}},
                    { :raw_data => [ 0b00001001, 0b11110110, 0b000011001, 0b11100110],
                      :packet => {:device_type=>"X10", :house_code => 'F', :dim => 'DIM'}}
                  ]


    ds10packets.each do |p|
      assert_true @ds10a.valid_packet?(p[:raw_data])
      assert_equal p[:packet], @ds10a.process_packet(p[:raw_data]) 
    end
  end

  # tests that bad packets aren't accepted by DS10A parser
  test "invalid packets" do
    badpackets = [[ 0b00101111, 0b11010000, 0b01011111, 0b10100000],
                  [ 0b01001111, 0b10110000, 0b00011111, 0b11100000],
                  [ 0b00101111, 0b11010000, 0b00111111, 0b11000000],
                  [ 0b00101111, 0b11010000, 0b00011111, 0b11100001]]

    badpackets.each do |p|
      assert_false @ds10a.valid_packet?(p)
    end
  end
end