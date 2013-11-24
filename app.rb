require 'sinatra'
require 'sinatra/base'
require 'yaml'

require File.expand_path '../shades.rb', __FILE__

set :bind, '0.0.0.0'

ENV['RACK_ENV'] ||= "development"

class RemoteShadeControlApp < Sinatra::Base
  
  before do
    @settings = YAML.load_file("#{settings.root}/settings.yml")[ENV['RACK_ENV']]
    @shades = Shades.new(@settings)
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
  
  get '/auto' do
    @shades.auto_raise_and_lower
    redirect to('/')
  end
end
