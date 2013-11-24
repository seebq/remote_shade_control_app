# test.rb
require File.expand_path '../test_helper.rb', __FILE__

class RemoteShadeControlAppTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_hello_world
    get '/'
    assert last_response.ok?
    assert_equal "Hello, World!", last_response.body
  end
end