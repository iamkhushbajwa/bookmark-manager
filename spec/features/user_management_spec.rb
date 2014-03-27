require 'spec_helper'
require_relative 'helpers/session'
require_relative 'helpers/http_stub'

include SessionHelpers
include HttpHelpers

feature "User signs up" do
  before(:each) do
    @from = "admin@bookmark-manager.com"
    @title = "Welcome to Bookmark Manager"
    @text = "Dear User, we would like to welcome you to Bookmark Manager, a place to share your favourite links with the world. Now you have signed up the world can see what links you have contributed and you can like links!"
    @to = "alice@example.com"
    stub_http(@from, @title, @text,@to)
  end

  scenario "when signing up and logging in" do
    lambda {sign_up}.should change(User, :count).by(1)
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq("alice@example.com")
  end

  scenario "with a password that doesn't match" do
    lambda {sign_up('a','a@a.com','pass','wrong')}.should change(User, :count).by(0)
    expect(current_path).to eq('/users')
    expect(page).to have_content("Sorry, your passwords don't match")
  end

  scenario "with an email that is already registered" do
    lambda { sign_up }.should change(User, :count).by(1)
    click_button 'Sign out'
    lambda { sign_up }.should change(User, :count).by(0)
    expect(page).to have_content("This email has already been taken")
  end

  scenario "then tries to sign up again" do
    sign_up
    visit '/users/new'
    expect(page).not_to have_content("Please Sign Up")
    expect(page).to have_content("Welcome, alice@example.com")
  end

end

feature "User signs in" do
  before(:each) do
    User.create(:username => 'test', :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
  end

  scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end

  scenario "then tries to sign in again" do
    sign_in('test@test.com', 'test')
    visit '/sessions/new'
    expect(page).not_to have_content("Please log in")
    expect(page).to have_content("Welcome, test@test.com")
  end

end

feature "User signs out" do
  before(:each) do
    User.create(:username => 'test', :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
  end
  scenario "while being signed in" do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Goodbye!")
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end