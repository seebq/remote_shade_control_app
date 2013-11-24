require 'sinatra'

set :bind, '0.0.0.0'

get '/' do
  erb :index
end

get '/up' do
  `./GPIO.sh 14`
  redirect to('/')
end

get '/stop' do
  `./GPIO.sh 13`
  redirect to('/')
end

get '/down' do
  `./GPIO.sh 12`
  redirect to('/')
end
