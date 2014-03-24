require 'bcrypt'

class User
  include DataMapper::Resource
  attr_reader :password
  attr_accessor :password_confirmation

  validates_confirmation_of :password

  property :id, Serial
  property :email, String
  property :password_digest, Text, :unique => true, :message => "This email is already taken"

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end
end