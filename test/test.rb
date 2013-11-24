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
    get '/up'
    assert last_response.redirect?
  end
  
end