require 'sinatra'
require 'sinatra/base'

require File.expand_path '../shades.rb', __FILE__

set :bind, '0.0.0.0'

class RemoteShadeControlApp < Sinatra::Base
  
  def test_mode?
    ENV['RACK_ENV'] == 'test'
  end
  
  before do
    @shades = Shades.new(test_mode?)
  end
  
  get '/' do
    erb :index
  end

  get '/up' do
    @shades.up
    redirect to('/')
  end

  get '/stop' do
    @shades.stop
    redirect to('/')
  end

  get '/down' do
    @shades.down
    redirect to('/')
  end
end
