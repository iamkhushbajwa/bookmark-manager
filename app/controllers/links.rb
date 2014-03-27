get '/links/new' do
  erb :"links/new"
end

post '/links' do
  url, title, user_id = params["url"], params["title"], session[:user_id] || 0
  tags = params["tags"].split(" ").map { |tag| Tag.first_or_create(:text => tag.downcase) }
  Link.create(:url => url, :title => title, :tags => tags, :user_id => user_id)
  redirect to('/')
end

get '/tags/:text' do
  tag = Tag.first(:text.like => params[:text].downcase)
  @links = tag ? tag.links : []
  @available_tags = Tag.all
  erb :index
end

post '/favourite' do
  link = Link.get(params[:link_id])
  user = User.get(session[:user_id])
  favourites = user.links
  favourites << link
  user.update(:links => favourites)
  redirect to('/')
end