class Link
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true
  property :url, String, :required => true
  property :description, Text
  property :user_id, String
  has n, :tags, :through => Resource
  has n, :users, :through => Resource
end