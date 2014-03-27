require 'sinatra'
require 'sinatra/partial'
require 'data_mapper'
require 'rack-flash'
require 'rest-client'
require 'time'
require './lib/link'
require './lib/user'
require './lib/tag'
require_relative 'helpers/user_helper'
require_relative 'data_mapper_setup'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash
set :partial_template_engine, :erb

API_KEY = ENV["MAILGUN_API_KEY"]
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/app23401830.mailgun.org"

get '/' do
  @links = Link.all
  @available_tags = Tag.all
  erb :index
end

post '/links' do
  url = params["url"]
  title = params["title"]
  user_id = session[:user_id] || 0
  tags = params["tags"].split(" ").map { |tag| Tag.first_or_create(:text => tag.downcase) }
  Link.create(:url => url, :title => title, :tags => tags, :user_id => user_id)
  redirect to('/')
end

get '/users/retrieve' do
  erb :"users/retrieve"
end

post '/users/retrieve' do
  user = User.first(:email => params[:email])
  if !user
    flash[:errors] = "Email is incorrect"
    redirect to('/users/retrieve')
  else
    user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
    user.password_token_timestamp = Time.now
    user.save
    send_password_token(user.password_token, user.email)
  end
end

def send_password_token(token,email)
  RestClient.post API_URL+"/messages",
    :from => "kh@example.com",
    :to => email,
    :subject => "Bookmark Manager Password Reset",
    :text => "To valued user you have recently requested a password reset,
      here is your reset url, please enter it into your browser: http://127.0.0.1:9393/users/reset/#{token}"
end

get '/users/reset/:token' do
  user = User.first(:password_token => params[:token])
  if !user
    flash[:errors] = "Token is incorrect or has already been used"
    redirect to('/users/retrieve')
  else
    if (Time.now - Time.parse(user.password_token_timestamp.to_s)) < (60*60)
      @token = params[:token]
      erb :"/users/new_password"
    else
      flash[:errors] = "Token has expired, please generate a new token"
      redirect to('/users/retrieve')
    end
  end
end

post '/users/new_password' do
  user = User.first(:password_token => params[:token])
  if !user
    flash[:errors] = "An error occured!"
    redirect to('/users/retrieve')
  else
    user.update(:password => params[:password], :password_confirmation => params[:password_confirmation], :password_token => "", :password_token_timestamp => nil)
    if user.save
      session[:user_id] = user.id
      redirect to('/sessions/new')
    else
      flash.now[:errors] = user.errors.full_messages
      redirect to('/users/retrieve')
    end
  end
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
  tag = Tag.first(:text.like => params[:text].downcase)
  @links = tag ? tag.links : []
  @available_tags = Tag.all
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
  current_user ? (redirect to('/')) : (erb :"sessions/new")
end

get '/users/current' do
  @user_links = Link.all(:user_id => session[:user_id])
  @user_tags = Tag.all(:user_id => session[:user_id])
  @user_favs = User.get(session[:user_id]).links
  current_user ? (erb :"users/current") : (redirect to('/'))
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


