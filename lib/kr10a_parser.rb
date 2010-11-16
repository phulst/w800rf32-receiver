require 'x10_constants.rb'

# can determine whether or not a data packet is from a KR10A Security remote control
# and parse this packet into an event
#
# @Author Peter Hulst

class Kr10aParser
  include X10Constants

  # returns true if the bytes passed in are a valid packet for a KR10A remote
  def valid_packet?(bytes)
    (bytes[0] & 0x80 ==  0x80) &&                      # bit 7 of byte0 always high
    (bytes[0] & 0x0F == bytes[1] & 0x0F) &&   # lower nibble of byte0 and byte1 are identical
    ((bytes[0]>>4)^(bytes[1]>>4) == 0x0F) &&  # upper nibble are inverse of each other
    inverse_of?(bytes[2], bytes[3]) &&        # byte2 is inverse of byte3
    (bytes[2] >> 3 == 0b01100)                # bits 3-7 of byte2 is 01100
  end

  # proceses the packet and returns event object
  #
  def process_packet(data)
    data2 = data[2]

    if data2 & 0x0F == 0x00
      mode = SecurityMode::ARM
    elsif data2 & 0x0F == 0x01
      mode = SecurityMode::DISARM
    elsif data2 & 0x0F == 0x02
      mode = SecurityMode::LIGHTS_ON
    elsif data2 & 0x0F == 0x03
      mode = SecurityMode::LIGHTS_OFF
    elsif data2 & 0x0F == 0x04
      mode = SecurityMode::PANIC
    end

    { :device_type => Device::KR10A,
      :mode => mode,
      :address => data[1].to_s(16)
    }
  end

  private

  def inverse_of?(a, b)
    a^b == 0xff
  end
end