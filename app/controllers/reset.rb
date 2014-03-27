require_relative '../email'

get '/users/retrieve' do
  erb :"users/retrieve"
end

post '/users/retrieve' do
  user = User.first(:email => params[:email])
  if !user
    flash[:errors] = "Email is incorrect"
    redirect to('/users/retrieve')
  else
    user.generate_password_token
    message = "To valued user you have recently requested a password reset,
               here is your reset url, please enter it into your browser:
               http://127.0.0.1:9393/users/reset/#{user.password_token}"
    Email.new("Bookmark Manager", user.email, "Bookmark Manager Password Reset", message)
    erb :"/users/email_sent"
  end
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
      redirect to('/sessions/new')
    else
      flash.now[:errors] = user.errors.full_messages
      redirect to('/users/retrieve')
    end
  end
end