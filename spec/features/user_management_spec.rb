require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "User signs up" do
  scenario "when signing up and logging in" do
    lambda {sign_up}.should change(User, :count).by(1)
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq("alice@example.com")
  end

  scenario "with a password that doesn't match" do
    lambda {sign_up('a@a.com','pass','wrong')}.should change(User, :count).by(0)
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
    User.create(:email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
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
    User.create(:email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
  end
  scenario "while being signed in" do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Good bye!")
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end

feature "Favourites" do
  scenario "User favourites a link" do
    User.create(:email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
    Link.create(:url => "http://www.google.com", :title => "Google", :tags => [Tag.first_or_create(:text => 'search')], :user_id => 1)
    sign_in('test@test.com', 'test')
    user = User.first
    visit '/'
    click_button 'Favourite Google'
    expect(user.links.map(&:title)).to include("Google")
    expect(page).to have_content("1 added yesterday by ")
  end

  scenario "Users can see their link, tags & favourites" do
    User.create(:id => 20, :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
    Link.create(:url => "http://www.google.com", :title => "Google", :tags => [Tag.first_or_create(:text => 'searching', :user_id => 20)], :user_id => 20)
    Link.create(:url => "http://www.yahoo.com", :title => "Yahoo", :tags => [Tag.first_or_create(:text => 'entertainmenting', :user_id => 20)], :user_id => 20)
    Link.create(:url => "http://www.bing.com", :title => "Bing", :tags => [Tag.first_or_create(:text => 'crap', :user_id => 21)], :user_id => 21)
    Link.create(:url => "http://www.sam.com", :title => "Sam", :tags => [Tag.first_or_create(:text => 'trying', :user_id => 21)], :user_id => 21)
    sign_in('test@test.com', 'test')
    visit '/'
    click_button 'Favourite Sam'
    visit '/users/current'
    expect(page).to have_content("Profile")

    expect(page).to have_content("Google")
    expect(page).to have_content("Yahoo")
    expect(page).not_to have_content("Bing")

    expect(page).to have_content("Searching")
    expect(page).to have_content("Entertainmenting")
    expect(page).not_to have_content("Crap")

    expect(page).to have_content("Sam")
  end
end

feature "Forgotten password" do
  before(:each) do
    User.create(:id => 1, :email => 'khushkaran@me.com', :password => 'test', :password_confirmation => 'test')
  end
  scenario "Users can reset their password" do
    user = User.first
    visit '/sessions/new'
    click_on "Forgotten password?"
    expect(page).to have_content("Password Retrieval")
    expect(page).not_to have_content("Please log in")
    fill_in 'email', with: 'khushkaran@me.com'
    click_button 'Reset'
    visit "/users/reset/#{user.password_token}"
    fill_in 'password', with: 'test1'
    fill_in 'password_confirmation', with: 'test1'
    click_button 'Submit'
    sign_in('khushkaran@me.com','test1')
    expect(page).to have_content("Welcome, ")
  end
end
