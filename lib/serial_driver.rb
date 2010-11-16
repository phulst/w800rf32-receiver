require 'rubygems'
require "serialport"

class SerialDriver

  # constructor
  def initialize(port, baud = 9600, data_bits = 8, stop_bits = 1, parity = SerialPort::NONE )
    #@sp = SerialPort.new port, { "baud" => baud, "data_bits" => data_bits, "stop_bits" => stop_bits, "parity" => parity }
    #@sp = SerialPort.new port, { "baud" => baud, "data_bits" => data_bits, "stop_bits" => stop_bits, "parity" => parity }
    @sp = SerialPort.new port, baud

    #sp.write "AT\r\n"
    #puts sp.read   # hopefully "OK" ;-)
  end

  # sends a command to the serial device. If a response is expected and must be returned, one of the
  # following options must be set:
  # :expected_resp_size => number   - to define a fixed number of characters that is expected
  # :expected_term_char => char     - to specify the termination char(s). The driver will read until these chars are received
  # :first_char_sets_resp_length => n - for specific devices that use the first byte(s) of response to indicate
  #                                 the total length of response.
  #
  # if none of the above options are specified, no response is expected and it will wait for a number of milliseconds
  # specified by :wait_ms_after before returning. If this option isn't set, it will return immediately.
  #
  def sendData(cmd, opts = {})
    opts = { :expected_resp_size => 0,
             :expected_term_char => nil,
             :read_timeout => 0,
             :first_char_sets_resp_length => 0,
             :wait_ms_after => 0
           }.merge(opts)


    #@sp.read_timeout=opts[:read_timeout]
    @sp.flush
    @sp.read_timeout=500

    puts "sending command #{cmd}"
    cmd.each_byte do |b|
      @sp.putc b
    end

    wait_ms(opts[:wait_ms_after]) if (opts[:wait_ms_after] > 0)

    #sleep (0.1)

    receive(opts)
  end


  def receive(opts = {})
    opts = { :expected_resp_size => 0,
             :expected_term_char => nil,
             :read_timeout => 0,
             :first_char_sets_resp_length => 0,
             :wait_ms_after => 0
           }.merge(opts)

    response = []

    #@sp.read_timeout = 10000

    if (opts[:expected_resp_size] > 0)
      # expecting a fixed number of bytes/characters in response
      puts "reading data"

      until (response.length == opts[:expected_resp_size])
        ch = @sp.getc
        response << ch
        #puts "read char #{ch.to_s(2).rjust(8, '0')}"
      end

      #exit 0 if (bytes.length > 0)

    elsif (opts[:expected_term_char])
      # expected that response will always end with given termination char
      # Read until we receive that char (or until we get a read timeout, if specified)
      ch = ''
      until (ch == opts[:expected_term_char])
        ch = @sp.getc
        response << ch
        #puts "read char: #{ch}"
      end
      puts "full response = #{response.join}"


    elsif (opts[:first_char_sets_resp_length] > 0)
      # first n bytes of response specify the length of response
      len = @sp.getc
      if (opts[:first_char_sets_resp_length] == 2)
        len2 = @sp.getc
        # assume first byte is MSB, and second byte is LSB
        len = len.to_i * 256 + len2.to_i
        fix this

      end

    elsif block_given?
      # block passed in will determine whether read is complete or not
      resp = false
      while !resp
        response << @sp.getc
        # code block passed in will return false if more bytes should be read, or
        # return byte array of bytes to return as packet
        resp = yield(response)
      end
      response = resp

    end
    response
  end

  def close
    @sp.close
  end

  private

  # sleeps a specified number of milliseconds. Note that is only only reasonably accurate if the
  # specified time exceeds 1/100th of a second (10ms). See also
  # http://codeidol.com/other/rubyckbk/Date-and-Time/Waiting-a-Certain-Amount-of-Time/
  def wait_ms(ms)
    if (ms > 0)
      sleep(ms/1000)
    end
  end

  #Code here
end