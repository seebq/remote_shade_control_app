require 'date'
require 'solareventcalculator'

class Shades
  
  def initialize(test_mode=false)
    @test_mode = test_mode
  end
  
  def test_mode?
    @test_mode
  end
  
  def current_location
    # hardcoded to Atlanta, GA
    [BigDecimal.new("33.7773"), BigDecimal.new("-84.3366")]
  end
  
  def current_timezone
    # hardcoded to Atlanta, GA
    'America/New_York'
  end
  
  def sunrise
    solar_event_calculator = SolarEventCalculator.new(Date.today, *current_location)
    local_official_sunrise = solar_event_calculator.compute_official_sunrise(current_timezone)
    local_official_sunrise.strftime("%-l:%M %P")
  end
  
  def sunset
    solar_event_calculator = SolarEventCalculator.new(Date.today, *current_location)
    local_official_sunset = solar_event_calculator.compute_official_sunset(current_timezone)
    local_official_sunset.strftime("%-l:%M %P")
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