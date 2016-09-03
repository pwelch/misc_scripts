require 'sinatra'
require 'json'

get '/' do
  request.ip
end

get '/json' do
  {ip: request.ip}.to_json
end
