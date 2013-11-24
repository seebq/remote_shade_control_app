class Shades
  
  def initialize(test_mode=false)
    @test_mode = test_mode
  end
  
  def test_mode?
    @test_mode
  end
  
  def up
    if test_mode?
      return "up"
    else
      `./GPIO.sh 14`
    end
  end
  
  def stop
    if test_mode?
      return "stop"
    else
      `./GPIO.sh 13`
    end
  end
  
  def down
    if test_mode?
      return "down"
    else
      `./GPIO.sh 12`
    end
  end
  
end