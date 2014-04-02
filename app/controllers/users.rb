require_relative 'reset'
require_relative '../email'

get '/users/new' do
  if current_user
    flash.now[:errors] = ["You are already signed up"]
    @links = Link.all
    @available_tags = Tag.all
    erb :index
  else
    @user = User.new
    erb :"users/new", :layout => !request.xhr?
  end
end

post '/users' do
  @user = User.create(:email => params[:email], :username => params[:username], :password => params[:password], :password_confirmation => params[:password_confirmation])
  if @user.save
    session[:user_id] = @user.id
    message = "Dear User, we would like to welcome you to Bookmark Manager, a place to share your favourite links with the world. Now you have signed up the world can see what links you have contributed and you can like links!"
    Email.new("admin@bookmark-manager.com", @user.email, "Welcome to Bookmark Manager", message)
    redirect to('/')
  else
    flash.now[:errors] = @user.errors.full_messages
    erb :"users/new"
  end
end

get '/users/current' do
  @user_links = Link.all(:user_id => session[:user_id])
  @user_tags = Tag.all(:user_id => session[:user_id])
  @user_favs = User.get(session[:user_id]).links
  current_user ? (erb :"users/current") : (redirect to('/'))
end