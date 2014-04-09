#!/usr/bin/env ruby

# usage write_packet.rb [channel] [command]
#   ex: write_packet.rb 2 up

require 'rubygems'
require 'serialport'

channel = ARGV[0]
button = ARGV[1]

sp = SerialPort.new "/dev/ttyUSB1", 9600, 8, 1, SerialPort::NONE

# packets for channels and buttons
packet = ""
if channel == "2"
  if button == "up"
    packet = [0x01, 0x07, 0x00, 0x05, 0x01, 0x02, 0x01, 0x00, 0xFF]
  elsif button == "down"
    packet = [0x01, 0x07, 0x00, 0x05, 0x01, 0x02, 0x02, 0x00, 0xFC]
  else
    # unknown
  end
elsif channel == "3"
  if button == "up"
    packet = [0x01, 0x07, 0x00, 0x05, 0x01, 0x03, 0x01, 0x00, 0xFE]
  elsif button == "down"
    packet = [0x01, 0x07, 0x00, 0x05, 0x01, 0x03, 0x02, 0x00, 0xFD]
  else
    # unknown
  end
elsif channel == "7"
  if button == "up"
    packet = [0x01, 0x07, 0x00, 0x05, 0x01, 0x07, 0x01, 0x00, 0xFA]
  elsif button == "down"
    packet = [0x01, 0x07, 0x00, 0x05, 0x01, 0x07, 0x02, 0x00, 0xF9]
  else
    # unknown
  end
end

sp.write(packet.pack('C*'))
