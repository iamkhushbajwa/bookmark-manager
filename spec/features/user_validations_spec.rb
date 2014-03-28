require 'spec_helper'
require_relative 'helpers/session'
require_relative 'helpers/http_stub'

include SessionHelpers
include HttpHelpers

feature "Users fail to satisfy conditions" do
	before(:each) do
		@from = "admin@bookmark-manager.com"
		@title = "Welcome to Bookmark Manager"
		@text = "Dear User, we would like to welcome you to Bookmark Manager, a place to share your favourite links with the world. Now you have signed up the world can see what links you have contributed and you can like links!"
		@to = "alice@example.com"
  end
  scenario "email should be valid" do
  	stub_http(@from, @title, @text,"dsnskjfns")
    lambda {sign_up("dsnskjfns","oranges","oranges")}.should change(User, :count).by(0)
  end

  scenario "email should be entered" do
  	stub_http(@from, @title, @text,"")
    lambda {sign_up("","oranges","oranges")}.should change(User, :count).by(0)
  end

  scenario "password should be entered" do
  	stub_http(@from, @title, @text, @to)
    lambda {sign_up("alice@example.com","","")}.should change(User, :count).by(0)
  end
end

feature "Users check the remember me box" do
  scenario "users should be remembered accross browser restarts" do
    stub_http(
      "admin@bookmark-manager.com", 
      "Welcome to Bookmark Manager", 
      "Dear User, we would like to welcome you to Bookmark Manager, a place to share your favourite links with the world. Now you have signed up the world can see what links you have contributed and you can like links!",
      "alice@example.com")
    sign_up
    click_button 'Sign out'
    visit '/sessions/new'
    fill_in 'email', :with => "alice@example.com"
    fill_in 'password', :with => "oranges!"
    check 'remember_me'
    click_button 'Sign in'
    expect(page).to have_content('Welcome, ')
    expire_cookies
    visit '/'
    expect(page).to have_content('Welcome, ')
  end
end