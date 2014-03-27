class Link
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true
  property :url, String
  property :user_id, String
  has n, :tags, :through => Resource
  has n, :users, :through => Resource
end