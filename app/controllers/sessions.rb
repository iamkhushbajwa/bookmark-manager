get '/sessions/new' do
  if current_user
    flash.now[:errors] = ["You are already logged in"]
    @links = Link.all
    @available_tags = Tag.all
    erb :index
  else
    erb :"sessions/new"
  end
end

post '/sessions' do
  email, password = params[:email], params[:password]
  user = User.authenticate(email, password)
  if user
    env['rack.session.options'].merge! expire_after: 2592000 if params[:remember_me] == "on"
    session[:user_id] = user.id
    redirect to('/')
  else
    flash[:errors] = ["The email or password is incorrect"]
    erb :"sessions/new"
  end
end

delete '/sessions' do
  flash[:notice] = "Goodbye!"
  session[:user_id] = nil
  redirect to('/')
  env['rack.session.options'].merge! expire_after: 0
end