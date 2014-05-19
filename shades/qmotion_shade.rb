require 'serialport'

# QMotion shades require a +channel+ and connect via a +serialport+.
# 
# channel is for the remote dial on the QMotion Connect device once programmed
# for a specific shade. Example:
#   channel: "2" 
# 
# serialport is for the port that the QMotion Connect device is connected to.
# Example:
#   serialport: "/dev/ttyUSB0"
# 
class QMotionShade < Shade
  
  attr_accessor :channel
  
  def initialize(options)
    @channel = options["channel"]
    @sp = SerialPort.new options["serialport"], 9600, 8, 1, SerialPort::NONE
    super(options)
  end
  
  def up
    write_packet(@channel, "up")
  end
  
  def stop
    write_packet(@channel, "stop")
  end
  
  def down
    write_packet(@channel, "down")
  end
  
  def write_packet(channel, button)
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
    @sp.write(packet.pack('C*'))
  end
end