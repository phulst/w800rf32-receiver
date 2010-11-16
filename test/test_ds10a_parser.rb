require 'helper.rb'
require "ds10a_parser"

# tests the DS10A parser
class TestDs10aParser < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @ds10a = Ds10aParser.new
  end

  # tests that valid packets are accepted by DS10A
  test "valid packet" do
    ds10packets = [ { :raw_data => [ 0b10110010, 0b01000010, 0b10100001, 0b01011110],
                      :packet => {:device_type=>"DS10A", :address=>"42", :low_bat=>true, :min_delay=>true, :state=>"CLOSED"}},
                    { :raw_data => [ 0b11000101, 0b00110101, 0b00000000, 0b11111111],
                      :packet => {:device_type=>"DS10A", :address=>"35", :low_bat=>false, :min_delay=>false, :state=>"OPEN"}}
                  ]

    ds10packets.each do |p|
      assert_true @ds10a.valid_packet?(p[:raw_data])
      assert_equal p[:packet], @ds10a.process_packet(p[:raw_data]) 
    end
  end

  # tests that bad packets aren't accepted by DS10A parser
  test "invalid packets" do
    badpackets = [[ 0b01110001, 0b10000001, 0b00000000, 0b11111111],
                  [ 0b10110010, 0b01000010, 0b10101001, 0b01011110]]

    badpackets.each do |p|
      assert_false @ds10a.valid_packet?(p)
    end
  end
end