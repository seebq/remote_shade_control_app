# SomfyShades simply send a command via GPIO.  No options are needed.
# 
class SomfyShade < Shade
  def up
    `./GPIO.sh 14`
  end
  
  def stop
    `./GPIO.sh 13`
  end
  
  def down
    `./GPIO.sh 12`
  end
end