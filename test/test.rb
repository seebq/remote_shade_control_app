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
    
    Shades.stub :new, shades do
      get '/'
      assert_match "The sun rises at 6:33 am", last_response.body
      assert_match "The sun sets at 8:42 pm", last_response.body
    end
  end
  
  def test_should_know_when_to_raise_shade
  end
  
end