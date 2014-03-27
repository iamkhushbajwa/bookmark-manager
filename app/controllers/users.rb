require_relative 'reset'

get '/users/new' do
  if current_user
    flash.now[:errors] = ["You are already signed up"]
    @links = Link.all
    @available_tags = Tag.all
    erb :index
  else
    @user = User.new
    erb :"users/new"
  end
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

get '/users/current' do
  @user_links = Link.all(:user_id => session[:user_id])
  @user_tags = Tag.all(:user_id => session[:user_id])
  @user_favs = User.get(session[:user_id]).links
  current_user ? (erb :"users/current") : (redirect to('/'))
end