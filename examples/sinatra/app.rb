require 'sinatra'

get '/' do
  erb :index
end

get '/hello/:name' do
  @name = params[:name]
  erb :show
end
