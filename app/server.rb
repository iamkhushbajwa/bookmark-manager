require 'sinatra'
require 'data_mapper'
env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
require './lib/link'
DataMapper.finalize
DataMapper.auto_upgrade!


get '/' do
  @links = Link.all
  erb :index
end

post '/links' do
  url = params["url"]
  title = params["title"]
  Link.create(:url => url, :title => title)
  redirect to ('/')
end