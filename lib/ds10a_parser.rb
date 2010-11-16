require 'x10_constants.rb'

# can determine whether or not a data packet is from a DS10A Door/Window sensor,
# and parse this packet into an event
#
# @Author Peter Hulst
class Ds10aParser
  include X10Constants

  # returns true if the bytes passed in are a valid packet for a DS10A door/window sensor
  def valid_packet?(bytes)
    # for the DS10A, the address pattern seems to be as follows:
    # (purely from experimentation)
    # for byte0 and byte1, lower nibbles are identical,
    # while upper nibbles are inverse of eachother
    #
    # byte 2 is used as follows:
    # bit 0 - open (if low) or closed (if high)
    # bit 5 - 1 for min, 0 for max
    # bit 7 - 1 for low battery
    # and bit 1,2,3,4,6 are always zero
    # byte 3 is inverse of byte 2
    (bytes[0] & 0x80 == 0x80) &&              # bit 7 of byte0 always high
    (bytes[0] & 0x0F == bytes[1] & 0x0F) &&   # lower nibble of byte0 and byte1 are identical
    ((bytes[0]>>4)^(bytes[1]>>4) == 0x0F) &&  # upper nibble are inverse of each other
    inverse_of?(bytes[2], bytes[3]) &&        # byte2 is inverse of byte3
    (0b01011110 & bytes[2] == 0)              # bits 0, 5, 7 must not be set on byte 2
  end

  # proceses the packet and returns event object
  #
  def process_packet(data)
    # address is determined as follows:
    # hex value of data byte 0, prefixed by high nibble of byte 1
    { :device_type  => Device::DS10A,
      :address      => (data[1]).to_s(16),
      :low_bat      => (data[2] & 0x80 == 0x80),
      :min_delay    => (data[2] & 0x20 == 0x20),
      :state        => (data[2] & 0x01 == 0x01) ? State::CLOSED : State::OPEN
    }
  end

  private

  def inverse_of?(a, b)
    a^b == 0xff
  end
end