$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'serial_driver.rb'
require 'ds10a_parser.rb'
require 'kr10a_parser.rb'
require 'generic_x10_parser.rb'


# receiver for the W800rf32 by WGL & Associates
# http://www.wgldesigns.com/w800.html
#
# This driver can receive and process data from the following devices:
#
# <li>Any generic X10 remotes that transmit on/off events with unit and house codes,
# such as the HR12 PalmPad remote, the MS14A and MS16A motion sensors, the KR19A SlimFire
# remote, and RSS18 HomePlate wall switches
#
# <li>The DS10A Door/Window sensors
#
# <li>The KR10A Security Remote control
#
# @Author Peter Hulst
#
class W800rf32Receiver

  # constructor. Pass in the serial port (ie "/dev/ttyS2") and an optional hash
  # of extra options. Options supported are:
  # <li>:debug_enabled - when true, will print debug serial data to console
  # <li>:filter_dups_within_secs - filter out multiple consecutive and identical events, if
  # they already happened within the past n seconds and if no other events were received in the meantime
  # <li>:parsers - array of parser instances. May be overridden to add additional
  # parsers for support for other devices
  #
  def initialize(port, opts = {})
    @options = { :debug_enabled => false,
                 :filter_dups_within_secs => false,
                 :parsers => [GenericX10Parser.new, Ds10aParser.new, Kr10aParser.new]
           }.merge(opts)

    @driver = SerialDriver.new(port, 4800) if port
    @parsers = @options[:parsers]
  end

  # the only public method in this class.
  # calls the block passed in on every packet that is received
  def on_message
    last_event = nil
    last_event_time = Time.now
    while true
      event = fetch_event
      check_time = Time.now - @options[:filter_dups_within_secs]
      if !(@options[:filter_dups_within_secs] > 0 &&
          last_event_time >= check_time &&
          event == last_event)
        yield event
        last_event = event
        last_event_time = Time.now
      else
        # event has already been received in last n seconds, ignroe
        log("filtering duplicate event")
      end
    end
  end


  # reads from serial port until a valid packet is received, then processes
  # and returns that
  def fetch_event
    parser = nil
    packet_bytes = @driver.receive do |bytes|
      bytes = reverse_bytes(bytes)
      log("received so far: #{as_binary(bytes)}")
      packet = false
      if bytes.length >= 4
        b = bytes[-4, 4] # check the last 4 bytes received
        parser = accepting_parser(b)
        if parser
          packet = b
        end
      end
      if (packet)
        log("Valid packet received: #{as_hex(packet)}")
      end
      packet
    end

    # at this point we should have a valid parser and a packet
    parser.process_packet(packet_bytes)
  end


  # checks if any of the known parsers will accept this as a valid data packet.
  # First starts with generic_x10_parser, then tries for less common X10 devices.
  # Returns the first parser instance in @parsers that accepts this packet,
  # nil if none accept it
  def accepting_parser(bytes)
    return false if bytes.length != 4  # any valid packet must be 4 bytes

    @parsers.each do |parser|
      if parser.valid_packet?(bytes)
        return parser; # found a parser that will accept this package
      end
    end
    nil
  end

  # reverses all bits in a byte
  def reverse_byte(b)
    b.to_s(2).rjust(8, '0').reverse.to_i(2)
  end

  # reverses all bits for each byte in an array
  def reverse_bytes(bytes)
    bytes.collect { |b| reverse_byte(b) }
  end

  # output packet in pretty hex format
  def as_hex(msg)
    str = ''
    msg.each { |m| str << "0x#{m.to_s(16).rjust(2, '0')} "}
    str
  end

  # output packet in pretty binary format
  def as_binary(msg)
    str = ''
    msg.each { |m| str << "0b#{m.to_s(2).rjust(8, '0')} "}
    str
  end

  # log a debug message to the console, if debug logging enabled
  def log(msg)
    puts msg if @options[:debug_enabled]
  end
end