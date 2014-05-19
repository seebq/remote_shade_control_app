# test.rb
require File.expand_path '../test_helper.rb', __FILE__

class RemoteShadeControlAppTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    RemoteShadeControlApp
  end

  def setup
    @settings = YAML.load_file("#{RemoteShadeControlApp.settings.root}/settings.yml")[ENV['RACK_ENV']]
    @shades = {}
    @settings["shades"].each do |shade|
      # create a hash of shades and load the type, i.e. SomfyShade.new() with settings
      @shades[shade["id"]] = eval(shade["shade_type"]).new(shade)
    end
    @shade = @shades["living_room"]
    super
  end

  def test_should_show_buttons
    get '/'
    assert last_response.ok?
    assert_match "up", last_response.body
    assert_match "stop", last_response.body
    assert_match "down", last_response.body
  end
  
  def test_should_show_auto_switch_for_each_shade
    get '/'
    assert last_response.ok?
    @settings["shades"].each do |shade|
      assert_match "auto-switch-" + shade["id"], last_response.body
    end
  end
  
  def test_should_send_up_command_for_shade
    shade = MiniTest::Mock.new
    shade.expect :up, nil
    
    Shade.stub :new, shade do
      get '/shades/living_room/up'
      assert last_response.redirect?
    end
  end
  
  def test_should_send_stop_command_for_shade
    shade = MiniTest::Mock.new
    shade.expect :stop, nil
    
    Shade.stub :new, shade do
      get '/shades/living_room/stop'
      assert last_response.redirect?
    end
  end
  
  def test_should_send_down_command_for_shade
    shade = MiniTest::Mock.new
    shade.expect :down, nil
    
    Shade.stub :new, shade do
      get '/shades/living_room/down'
      assert last_response.redirect?
    end
  end
  
  def test_should_show_sunrise_and_sunset_time_for_shades
    Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
      
    get '/'
    assert_match "The sun rises at 7:17 am.", last_response.body
    assert_match "The sun sets at 5:30 pm.", last_response.body
  end
  
  def test_should_show_raise_and_lower_settings_for_shades
    Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
    
    raise_up_time = @shade.raise_up_time
    lower_down_time = @shade.lower_down_time
    
    get '/'
    assert_match "Shades will rise #{raise_up_time} sunrise.", last_response.body
    assert_match "Shades will lower #{lower_down_time} sunset.", last_response.body
  end
  
  def test_can_toggle_the_automatic_functionality_for_shades
    Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
    
    get '/shades/living_room/auto_toggle', :toggle => "true"
    assert last_response.redirect?
    get '/'
    # has "checked" in the checkbox:
    assert_match /auto-switch-living_room(.*)\n(\s*)\<input type="checkbox" checked\>/, last_response.body
    get '/shades/living_room/auto_toggle', :toggle => "false"
    assert last_response.redirect?
    get '/'
    # does not have "checked" in the checkbox:
    assert_match /auto-switch-living_room(.*)\n(\s*)\<input type="checkbox" \>/, last_response.body
  end
  
  describe Shade do
    before do
      @settings = YAML.load_file("#{RemoteShadeControlApp.settings.root}/settings.yml")[ENV['RACK_ENV']]
      @shades = {}
      @settings["shades"].each do |shade|
        # create a hash of shades and load the type, i.e. SomfyShade.new() with settings
        @shades[shade["id"]] = eval(shade["shade_type"]).new(shade)
      end
      @shade = @shades["living_room"]
    end
    
    describe "when setup" do
      it "knows current location" do
        @shade.current_location.must_equal [BigDecimal.new("33.7773"), BigDecimal.new("-84.3366")]
      end
      
      it "knows current timezone" do
        @shade.current_timezone.must_equal 'America/New_York'
      end
      
      it "knows morning" do
        Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
        @shade.morning?.must_be :==, true, "6:14 am is in the morning"
        Timecop.freeze(Time.local(2013, 11, 24, 21, 42, 0)) # 2013-11-24 9:42:00 pm
        @shade.morning?.must_be :==, false, "9:42 pm not morning"
      end
      
      it "knows afternoon" do
        Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
        @shade.afternoon?.must_be :==, false, "6:14 am is not in the afternoon"
        Timecop.freeze(Time.local(2013, 11, 24, 21, 42, 0)) # 2013-11-24 9:42:00 pm
        @shade.afternoon?.must_be :==, true, "9:42 pm is afternoon"
      end
      
      it "knows to raise at the right times" do
        # on 11/24/2013 the sunrise is at 7:17 am
        # settings say 10 minutes before, so should raise at 7:07 am
        Timecop.freeze(Time.local(2013, 11, 24, 7, 2, 0)) # 2013-11-24 7:02:00 am
        @shade.should_raise?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 7, 6, 0)) # 2013-11-24 7:06:00 am
        @shade.should_raise?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 7, 7, 0)) # 2013-11-24 7:07:00 am
        @shade.should_raise?.must_be :==, true
        Timecop.freeze(Time.local(2013, 11, 24, 7, 8, 0)) # 2013-11-24 7:08:00 am
        @shade.should_raise?.must_be :==, true
      end
      
      it "knows to lower at the right times" do
        # on 11/24/2013 the sunset is at 5:30 pm
        # settings say 15 minutes after, so should lower at 5:45 pm
        Timecop.freeze(Time.local(2013, 11, 24, 17, 3, 0)) # 2013-11-24 5:03:00 pm
        @shade.should_lower?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 17, 44, 0)) # 2013-11-24 5:44:00 pm
        @shade.should_lower?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 17, 45, 0)) # 2013-11-24 5:45:00 pm
        @shade.should_lower?.must_be :==, true
        Timecop.freeze(Time.local(2013, 11, 24, 17, 46, 0)) # 2013-11-24 5:46:00 pm
        @shade.should_lower?.must_be :==, true
      end
      
      it "automatically raises and lowers at the right times" do
        Timecop.freeze(Time.local(2013, 11, 24, 6, 0, 0)) # 2013-11-24 6:00:00 am
        
        @shade.auto_lower # make sure was called the night before
        Timecop.freeze(Time.local(2013, 11, 24, 7, 2, 0)) # 2013-11-24 7:02:00 am
        @shade.auto_raise_and_lower.must_be_nil
        Timecop.freeze(Time.local(2013, 11, 24, 7, 7, 0)) # 2013-11-24 7:07:00 am
        @shade.auto_raise_and_lower.must_be :==, "up"
        
        # subsequent calls do nothing
        @shade.auto_raise_and_lower.must_be_nil
        
        Timecop.freeze(Time.local(2013, 11, 24, 17, 45, 0)) # 2013-11-24 5:45:00 pm
        @shade.auto_raise_and_lower.must_be :==, "down"
        
        # subsequent calls do nothing
        @shade.auto_raise_and_lower.must_be_nil
      end
      
      it "knows if it's toggled to automatically raise and lower" do
        @shade.shade_state = "off"
        assert @shade.auto_toggled?.must_be :==, false
        
        @shade.shade_state = "down"
        assert @shade.auto_toggled?.must_be :==, true
        
        @shade.shade_state = "on"
        assert @shade.auto_toggled?.must_be :==, true
        
        @shade.toggle_auto_functionality("false")
        assert @shade.auto_toggled?.must_be :==, false
        
        @shade.toggle_auto_functionality("true")
        assert @shade.auto_toggled?.must_be :==, true
      end
    end
  end
   
end