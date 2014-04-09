require 'sinatra'
require 'sinatra/base'
require 'yaml'

require File.expand_path '../shade.rb', __FILE__

set :bind, '0.0.0.0'

ENV['RACK_ENV'] ||= "development"

class RemoteShadeControlApp < Sinatra::Base
  
  before do
    @settings = YAML.load_file("#{settings.root}/settings.yml")[ENV['RACK_ENV']]
    @shades = {}
    @settings["shades"].each do |shade|
      @shades[shade["id"]] = Shade.new(shade)
    end
  end
  
  get '/' do
    erb :index
  end

  get '/shades/:id/up' do
    @shades[params[:id]].up
    redirect to('/')
  end

  get '/shades/:id/stop' do
    @shades[params[:id]].stop
    redirect to('/')
  end

  get '/shades/:id/down' do
    @shades[params[:id]].down
    redirect to('/')
  end
  
  get '/shades/:id/auto' do
    @shades[params[:id]].auto_raise_and_lower
    redirect to('/')
  end
  
  get '/shades/:id/auto_toggle' do
    @shades[params[:id]].toggle_auto_functionality(params[:toggle])
    redirect to('/')
  end
  
  # get '/auto' do
  #   @shades.auto_raise_and_lower
  #   redirect to('/')
  # end
  # 
  # get '/auto_toggle' do
  #   @shades.toggle_auto_functionality(params[:toggle])
  #   redirect to('/')
  # end

end
