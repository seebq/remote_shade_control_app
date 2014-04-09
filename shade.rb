require 'date'
require 'active_support/time'
require 'chronic'
require 'solareventcalculator'

# A shade knows its state (whether it is up or down) and the commands to raise, stop, and lower
# 
class Shade

  attr_accessor :name
  attr_accessor :id
  attr_accessor :shade_button_up
  attr_accessor :shade_button_stop
  attr_accessor :shade_button_down
  attr_accessor :raise_up_time
  attr_accessor :lower_down_time
  
  def initialize(options)
    @name = options["name"]
    @id = options["id"]
    @shade_button_up = options["shade_button_up"]
    @shade_button_stop = options["shade_button_stop"]
    @shade_button_down = options["shade_button_down"]
    @raise_up_time = options["raise_up_time"]
    @lower_down_time = options["lower_down_time"]
    # create state file if it doesn't exist with auto on
    # if !File.exists?(self.shade_state_file_name)
    #   File.open(self.shade_state_file_name, 'w+') {|f| f.write("on")}
    # end
  end
  
  def shade_state=(new_shade_state)
    File.open("/tmp/#{id}", 'w+') {|f| f.write(new_shade_state)}
  end
  
  def shade_state
    File.open("/tmp/#{id}", 'a+').read.strip
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
    Time.now >= Chronic.parse("#{@raise_up_time} #{sunrise}")
  end
  
  def should_lower?
    # * current time is equal to or past the lower down time
    Time.now >= Chronic.parse("#{@lower_down_time} #{sunset}")
  end
  
  def lowered?
    self.shade_state == "down" || self.shade_state == "on"
  end
  
  def raised?
    self.shade_state == "up" || self.shade_state == "on"
  end
  
  def auto_toggled?
    self.shade_state != "off"
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
    self.shade_state = "up"
    return "up"
  end
  
  def auto_lower
    down
    self.shade_state = "down"
    return "down"
  end
  
  def toggle_auto_functionality(toggle)
    if toggle == "true"
      self.shade_state = "on"
    elsif toggle == "false"
      self.shade_state = "off"
    else
      # do nothing
    end
  end
  
  def up
    `#{@shade_button_up}`
  end
  
  def stop
    `#{@shade_button_stop}`
  end
  
  def down
    `#{@shade_button_down}`
  end
  
end