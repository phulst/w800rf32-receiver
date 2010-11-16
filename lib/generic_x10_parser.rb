require 'x10_constants.rb'

# Can determine whether or not a data packet is from a Generic X10 device,
# and parse this packet into an event
#
# Devices that have been tested with this class:
#
# Eagle Eye MS14A and Active Eye MS16A motion sensors
# SlimFire remote KR19A
# PalmPad remote control HR12A
#
# @Author Peter Hulst
class GenericX10Parser
  include X10Constants
  
  # returns true if the bytes passed in are a valid packet for a generic X10 event
  def valid_packet?(bytes)
    (bytes[0] & 0b11010000 == 0) &&     # bit 4,6,7 byte0 are 0,
    (bytes[2] & 0b11100000 == 0) &&     # bits 5,6,7 of byte 2 always 0
    inverse_of?(bytes[0], bytes[1]) &&  # byte0, byte1 and byte2, byte3 pairs are inverse of each other  
    inverse_of?(bytes[2], bytes[3])
  end

  # processes the packet and returns event object
  def process_packet(data)
    data1 = data[0]
    data2 = data[2]

    #puts "data1 = #{data1.to_s(2).rjust(8, '0')}"
    #puts "data2 = #{data2.to_s(2).rjust(8, '0')}"

    house_code = 0x0F & data1
    unit = (data2 & 0x18) >> 3 # bit 3 and 3 of data2 become bit 0 and 1 of unit
    unit |= 0x04 if (0x02 & data2) > 0
    unit |= 0x08 if (0x20 & data1) > 0
    unit += 1

    if (data1 & 0b11010000 == 0x00) && (data2 & 0b11100000 == 0x00)
      # 3 high bytes of data1 are 0, and byte 4,6 and 7 of data2 are 0
      # this is a regular keypad/switch device
      off = (0x04 & data2) > 0

      event = {  :device_type => Device::X10,
                 :house_code =>  HouseCodes[house_code] }

      if (data2 == 0x11)
        event[:dim] = LightLevel::BRIGHT
      elsif (data2 == 0x19)
        event[:dim] = LightLevel::DIM
      else
        event[:unit] = unit
        event[:state] = off ? State::OFF : State::ON
      end
    end
    event
  end

  private

  def inverse_of?(a, b)
    a^b == 0xff
  end
end