require 'bcrypt'

class User
  include DataMapper::Resource
  attr_reader :password
  attr_accessor :password_confirmation

  validates_confirmation_of :password, :message => "Sorry, your passwords don't match"
  # validates_presence_of :password, :message => "Sorry, a password is required"

  property :id, Serial
  property :email, String, :unique => true, :message => "This email has already been taken", :format => :email_address, :required => true
  property :password_digest, Text, :required => true
  property :password_token, Text
  property :password_token_timestamp, DateTime
  has n, :links, :through => Resource

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password) if password.length > 0
  end

  def generate_password_token
    self.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
    self.password_token_timestamp = Time.now
    self.save
  end

  def self.authenticate(email,password)
    user = first(:email => email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end
end