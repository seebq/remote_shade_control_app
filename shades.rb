require 'date'
require 'active_support/time'
require 'chronic'
require 'solareventcalculator'

class Shades
  
  attr_accessor :settings
  
  def initialize(settings)
    @settings = settings
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
  
  def morning?
    # between midnight and noon
    midnight = Time.now.midnight
    noon = Time.now.midnight + 12.hours
    return Time.now > midnight && Time.now < noon
  end
  
  def afternoon?
    # between noon and midnight tomorrow
    noon = Time.now.midnight + 12.hours
    tomorrow_midnight = Time.now.tomorrow.midnight
    return Time.now > noon && Time.now < tomorrow_midnight
  end
  
  def should_raise?
    # * current time is equal to or past the raise up time
    Time.now >= Chronic.parse("#{@settings['raise_up_time']} #{sunrise}")
  end
  
  def should_lower?
    # * current time is equal to or past the lower down time
    Time.now >= Chronic.parse("#{@settings['lower_down_time']} #{sunset}")
  end
  
  def lowered?
    File.open('/tmp/.shades_state', 'a+').read.strip == "down"
  end
  
  def raised?
    File.open('/tmp/.shades_state', 'a+').read.strip == "up"
  end
  
  def auto_raise_and_lower
    if morning? && should_raise? && lowered?
      auto_raise
    elsif afternoon? && should_lower? && raised?
      auto_lower
    else
      nil
    end
  end
  
  def auto_raise
    up
    File.open('/tmp/.shades_state', 'w+') {|f| f.write("up") }
    return "up"
  end
  
  def auto_lower
    down
    File.open('/tmp/.shades_state', 'w+') {|f| f.write("down") }
    return "down"
  end
  
  def up
    `#{@settings['shade_button_up']}`
  end
  
  def stop
    `#{@settings['shade_button_stop']}`
  end
  
  def down
    `#{@settings['shade_button_down']}`
  end
  
end