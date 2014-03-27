require 'sinatra'
require 'sinatra/partial'
require 'data_mapper'
require 'rack-flash'
require 'rest-client'
require 'time'
require './lib/link'
require './lib/user'
require './lib/tag'
require_relative 'helpers/user_helper'
require_relative 'data_mapper_setup'
require_relative 'controllers/application'
require_relative 'controllers/links'
require_relative 'controllers/users'
require_relative 'controllers/sessions'
enable :sessions
set :session_secret, 'super secret'
use Rack::Flash
set :partial_template_engine, :erb

API_KEY = ENV["MAILGUN_API_KEY"]
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/app23401830.mailgun.org"