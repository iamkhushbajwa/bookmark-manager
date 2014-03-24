require 'capybara/rspec'
require './app/server'

Capybara.app = Sinatra::Application.new