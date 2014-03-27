require 'spec_helper'
require_relative 'helpers/session'
require_relative 'helpers/http_stub'

include SessionHelpers
include HttpHelpers

feature "Resetting a forgotten password" do
  before(:each) do
    User.create(
      :id => 1, 
      :email => 'test@example.com', 
      :username => 'test',
      :password => 'test', 
      :password_confirmation => 'test', 
      :password_token => 'RESET_TOKEN', 
      :password_token_timestamp => Time.now)
  end

  scenario "Users can reset their password" do
    visit '/sessions/new'
    click_on "Forgotten password?"
    expect(page).to have_content("Password Retrieval")
    expect(page).not_to have_content("Please log in")
    fill_in 'email', with: 'test@example.com'
    User.any_instance.stub(:generate_password_token).and_return(true)
    stub_http("admin@bookmark-manager.com",
              "Bookmark Manager Password Reset",
              "To valued user you have recently requested a password reset,\n      here is your reset url, please enter it into your browser: http://127.0.0.1:9393/users/reset/RESET_TOKEN",
              "khushkaran@me.com")
  end

  scenario "can login with a reset password " do
    visit "/users/reset/RESET_TOKEN"
    fill_in 'password', with: 'test1'
    fill_in 'password_confirmation', with: 'test1'
    click_button 'Submit'
    sign_in('test@example.com','test1')
    expect(page).to have_content("Welcome, ")
  end
end