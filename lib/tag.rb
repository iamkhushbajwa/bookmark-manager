class Tag
  include DataMapper::Resource

  has n, :links, :through => Resource

  property :id, Serial
  property :text, String, :required => true
  property :user_id, String
  
end