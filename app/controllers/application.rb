get '/' do
  @links = Link.all
  @available_tags = Tag.all
  erb :index
end