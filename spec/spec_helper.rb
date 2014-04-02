ENV["RACK_ENV"] = 'test'
require './app/server'
require 'database_cleaner'
require 'capybara/rspec'
require 'webmock/rspec'
require 'capybara/poltergeist'
require 'show_me_the_cookies'

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include ShowMeTheCookies, :type => :feature
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end