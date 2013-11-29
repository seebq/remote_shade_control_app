# test.rb
require File.expand_path '../test_helper.rb', __FILE__

class RemoteShadeControlAppTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    RemoteShadeControlApp
  end

  def test_should_show_buttons
    get '/'
    assert last_response.ok?
    assert_match "up", last_response.body
    assert_match "stop", last_response.body
    assert_match "down", last_response.body
  end
  
  def test_should_show_auto_switch
    get '/'
    assert last_response.ok?
    assert_match "auto", last_response.body
  end
  
  def test_should_send_up_command
    shades = MiniTest::Mock.new
    shades.expect :up, nil
    
    Shades.stub :new, shades do
      get '/up'
      assert last_response.redirect?
    end
  end
  
  def test_should_send_stop_command
    shades = MiniTest::Mock.new
    shades.expect :stop, nil
    
    Shades.stub :new, shades do
      get '/stop'
      assert last_response.redirect?
    end
  end

  def test_should_send_down_command
    shades = MiniTest::Mock.new
    shades.expect :down, nil
    
    Shades.stub :new, shades do
      get '/down'
      assert last_response.redirect?
    end
  end
  
  def test_should_show_sunrise_and_sunset_time
    shades = MiniTest::Mock.new
    shades.expect :sunrise, "6:33 am"
    shades.expect :sunset, "8:42 pm"
    shades.expect :auto_toggled?, "true"
    
    Shades.stub :new, shades do
      get '/'
      assert_match "The sun rises at 6:33 am.", last_response.body
      assert_match "The sun sets at 8:42 pm.", last_response.body
    end
  end
  
  # TODO use settings file
  def test_should_show_raise_and_lower_settings
    get '/'
    assert_match "Shades will rise 10 minutes before sunrise.", last_response.body
    assert_match "Shades will lower 15 minutes after sunset.", last_response.body
  end
  
  def test_can_toggle_the_automatic_functionality
    get '/auto_toggle', :toggle => "true"
    assert last_response.redirect?
  end
  
  describe Shades do
    before do
      @settings = YAML.load_file("#{RemoteShadeControlApp.settings.root}/settings.yml")[ENV['RACK_ENV']]
      @shades = Shades.new(@settings)
    end
    
    describe "when setup" do
      it "knows current location" do
        @shades.current_location.must_equal [BigDecimal.new("33.7773"), BigDecimal.new("-84.3366")]
      end
      
      it "knows current timezone" do
        @shades.current_timezone.must_equal 'America/New_York'
      end
      
      it "knows morning" do
        Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
        @shades.morning?.must_be :==, true, "6:14 am is in the morning"
        Timecop.freeze(Time.local(2013, 11, 24, 21, 42, 0)) # 2013-11-24 9:42:00 pm
        @shades.morning?.must_be :==, false, "9:42 pm not morning"
      end
      
      it "knows afternoon" do
        Timecop.freeze(Time.local(2013, 11, 24, 6, 14, 0)) # 2013-11-24 6:14:00 am
        @shades.afternoon?.must_be :==, false, "6:14 am is not in the afternoon"
        Timecop.freeze(Time.local(2013, 11, 24, 21, 42, 0)) # 2013-11-24 9:42:00 pm
        @shades.afternoon?.must_be :==, true, "9:42 pm is afternoon"
      end
      
      it "knows to raise at the right times" do
        # on 11/24/2013 the sunrise is at 7:17 am
        # settings say 10 minutes before, so should raise at 7:07 am
        Timecop.freeze(Time.local(2013, 11, 24, 7, 2, 0)) # 2013-11-24 7:02:00 am
        @shades.should_raise?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 7, 6, 0)) # 2013-11-24 7:06:00 am
        @shades.should_raise?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 7, 7, 0)) # 2013-11-24 7:07:00 am
        @shades.should_raise?.must_be :==, true
        Timecop.freeze(Time.local(2013, 11, 24, 7, 8, 0)) # 2013-11-24 7:08:00 am
        @shades.should_raise?.must_be :==, true
      end
      
      it "knows to lower at the right times" do
        # on 11/24/2013 the sunset is at 5:30 pm
        # settings say 15 minutes after, so should lower at 5:45 pm
        Timecop.freeze(Time.local(2013, 11, 24, 17, 3, 0)) # 2013-11-24 5:03:00 pm
        @shades.should_lower?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 17, 44, 0)) # 2013-11-24 5:44:00 pm
        @shades.should_lower?.must_be :==, false
        Timecop.freeze(Time.local(2013, 11, 24, 17, 45, 0)) # 2013-11-24 5:45:00 pm
        @shades.should_lower?.must_be :==, true
        Timecop.freeze(Time.local(2013, 11, 24, 17, 46, 0)) # 2013-11-24 5:46:00 pm
        @shades.should_lower?.must_be :==, true
      end
      
      it "automatically raises and lowers at the right times" do
        Timecop.freeze(Time.local(2013, 11, 24, 6, 0, 0)) # 2013-11-24 6:00:00 am
        
        @shades.auto_lower # make sure was called the night before
        Timecop.freeze(Time.local(2013, 11, 24, 7, 2, 0)) # 2013-11-24 7:02:00 am
        @shades.auto_raise_and_lower.must_be_nil
        Timecop.freeze(Time.local(2013, 11, 24, 7, 7, 0)) # 2013-11-24 7:08:00 am
        @shades.auto_raise_and_lower.must_be :==, "up"
        
        # subsequent calls do nothing
        @shades.auto_raise_and_lower.must_be_nil
        
        Timecop.freeze(Time.local(2013, 11, 24, 17, 45, 0)) # 2013-11-24 5:45:00 pm
        @shades.auto_raise_and_lower.must_be :==, "down"
        
        # subsequent calls do nothing
        @shades.auto_raise_and_lower.must_be_nil
      end
      
      it "knows if it's toggled to automatically raise and lower" do
        assert @shades.auto_toggled? # on by default
        
        @shades.toggle_auto_functionality("false")
        assert @shades.auto_toggled?.must_be :==, false
        
        @shades.toggle_auto_functionality("true")
        assert @shades.auto_toggled?.must_be :==, true
      end
    end
  end
  
end