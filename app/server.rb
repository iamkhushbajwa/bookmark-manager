require 'sinatra'
require 'sinatra/partial'
require 'data_mapper'
require 'rack-flash'
require './lib/link'
require './lib/user'
require './lib/tag'
require_relative 'helpers/user_helper'
require_relative 'data_mapper_setup'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash
set :partial_template_engine, :erb

get '/' do
  @links = Link.all
  tags = Tag.all
  @available_tags = tags.map{|tag| tag.text}.join(", ")

  erb :index
end

post '/links' do
  url = params["url"]
  title = params["title"]
  user_id = session[:user_id] || 0
  tags = params["tags"].split(" ").map { |tag| Tag.first_or_create(:text => tag) }
  Link.create(:url => url, :title => title, :tags => tags, :user_id => user_id)
  redirect to('/')
end

post '/favourite' do
  link = Link.get(params[:link_id])
  user = User.get(session[:user_id])
  favourites = user.links
  favourites << link
  user.update(:links => favourites)
  redirect to('/')
end

get '/links/new' do
  erb :"links/new"
end

get '/tags/:text' do
  tag = Tag.first(:text => params[:text])
  @links = tag ? tag.links : []
  erb :index
end

get '/users/new' do
  @user = User.new
  erb :"users/new"
end

post '/users' do
  @user = User.create(:email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
  if @user.save
    session[:user_id] = @user.id
    redirect to('/')
  else
    flash.now[:errors] = @user.errors.full_messages
    erb :"users/new"
  end
end

get '/sessions/new' do
  erb :"sessions/new"
end

post '/sessions' do
  email, password = params[:email], params[:password]
  user = User.authenticate(email, password)
  if user
    session[:user_id] = user.id
    redirect to('/')
  else
    flash[:errors] = ["The email or password is incorrect"]
    erb :"sessions/new"
  end
end

delete '/sessions' do
  flash[:notice] = "Good bye!"
  session[:user_id] = nil
  redirect to('/')
end


