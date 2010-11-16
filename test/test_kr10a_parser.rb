require 'helper.rb'
require "kr10a_parser"

# tests the KR10A parser
class TestKr10aParser < Test::Unit::TestCase

  def setup
    @ds10a = Kr10aParser.new
  end

  # tests that valid packets are accepted
  test "valid packet" do
    ds10packets = [ { :raw_data => [ 0b10110010, 0b01000010, 0b01100000, 0b10011111],
                      :packet => {:device_type=>"KR10A", :address=>"42", :mode => 'ARM'}},
                    { :raw_data => [ 0b10010110, 0b01100110, 0b01100001, 0b10011110],
                      :packet => {:device_type=>"KR10A", :address=>"66", :mode => 'DISARM'}},
                    { :raw_data => [ 0b11100001, 0b00010001, 0b01100010, 0b10011101],
                      :packet => {:device_type=>"KR10A", :address=>"11", :mode => 'LIGHTS_ON'}},
                    { :raw_data => [ 0b11001100, 0b00111100, 0b01100011, 0b10011100],
                      :packet => {:device_type=>"KR10A", :address=>"3c", :mode => 'LIGHTS_OFF'}},
                    { :raw_data => [ 0b10111010, 0b01001010, 0b01100100, 0b10011011],
                      :packet => {:device_type=>"KR10A", :address=>"4a", :mode => 'PANIC'}},
                  ]


    ds10packets.each do |p|
      assert_true @ds10a.valid_packet?(p[:raw_data])
      assert_equal p[:packet], @ds10a.process_packet(p[:raw_data]) 
    end
  end

  # tests that bad packets aren't accepted by KR10A parser
  test "invalid packets" do
    badpackets = [[ 0b10110010, 0b01000010, 0b01101000, 0b10010111],
                  [ 0b00110010, 0b11000010, 0b01100000, 0b10011111],
                  [ 0b10110010, 0b01000010, 0b11100000, 0b00011111],
                  [ 0b10110010, 0b01000000, 0b01100000, 0b10011111]]

    badpackets.each do |p|
      assert_false @ds10a.valid_packet?(p)
    end
  end
end