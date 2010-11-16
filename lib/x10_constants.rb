# global constants for w800rf32 driver and related classes
#
# @Author Peter Hulst
module X10Constants

  # devices supported by the w800rf32 driver
  class Device
    X10         = "X10"
    DS10A       = "DS10A"
    KR10A       = "KR10A"
  end

  # house code lookup table for generic X10 devices
  HouseCodes = {0b0110 => 'A',
                0b1110 => 'B',
                0b0010 => 'C',
                0b1010 => 'D',
                0b0001 => 'E',
                0b1001 => 'F',
                0b0101 => 'G',
                0b1101 => 'H',
                0b0111 => 'I',
                0b1111 => 'J',
                0b0011 => 'K',
                0b1011 => 'L',
                0b0000 => 'M',
                0b1000 => 'N',
                0b0100 => 'O',
                0b1100 => 'P' }

  # light level for dim/bright used by generic X10 devices
  class LightLevel
    BRIGHT      = "BRIGHT"
    DIM         = "DIM"
  end

  # States used by X10 devices. Generic X10 devices use ON/OFF, while
  # the DS10A door/window sensor uses CLOSED/OPEN
  class State
    OFF         = "OFF"
    ON          = "ON"
    CLOSED      = "CLOSED"
    OPEN        = "OPEN"
  end

  # security modes used by the KR10A Security Remote Control
  class SecurityMode
    ARM         = "ARM"
    DISARM      = "DISARM"
    PANIC       = "PANIC"
    LIGHTS_ON   = "LIGHTS_ON"
    LIGHTS_OFF  = "LIGHTS_OFF"
  end

end