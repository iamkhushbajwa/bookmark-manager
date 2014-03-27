require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "User signs up" do
  before(:each) do
    stub_request(:post, "https://api:key-5nf12qypu5-l7q1-lfhjazkd6xj97d75@api.mailgun.net/v2/app23401830.mailgun.org/messages").
            with(:body => {"from"=>"admin@bookmark-manager.com",
                           "subject"=>"Welcome to Bookmark Manager",
                           "text"=>"Dear User, we would like to welcome you to Bookmark Manager, a place to share your favourite links with the world. Now you have signed up the world can see what links you have contributed and you can like links!",
                           "to"=>"alice@example.com"},
                 :headers => {'Accept'=>'*/*; q=0.5, application/xml',
                              'Accept-Encoding'=>'gzip, deflate',
                              'Content-Type'=>'application/x-www-form-urlencoded',
                              'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "", :headers => {})
  end
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
    expect(page).to have_content("Goodbye!")
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
    User.create(:id => 1, :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
    Link.create(:url => "http://www.google.com", :title => "Google", :tags => [Tag.first_or_create(:text => 'searching', :user_id => 1)], :user_id => 1)
    Link.create(:url => "http://www.yahoo.com", :title => "Yahoo", :tags => [Tag.first_or_create(:text => 'entertainmenting', :user_id => 1)], :user_id => 1)
    Link.create(:url => "http://www.bing.com", :title => "Bing", :tags => [Tag.first_or_create(:text => 'crap', :user_id => 2)], :user_id => 2)
    Link.create(:url => "http://www.sam.com", :title => "Sam", :tags => [Tag.first_or_create(:text => 'trying', :user_id => 2)], :user_id => 2)
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

feature "Resetting a forgotten password" do
  before(:each) do
    User.create(
      :id => 1, 
      :email => 'khushkaran@me.com', 
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
    fill_in 'email', with: 'khushkaran@me.com'
    User.any_instance.stub(:generate_password_token).and_return(true)
    stub_request(:post, "https://api:key-5nf12qypu5-l7q1-lfhjazkd6xj97d75@api.mailgun.net/v2/app23401830.mailgun.org/messages").
            with(:body => {"from"=>"admin@bookmark-manager.com",
                           "subject"=>"Bookmark Manager Password Reset",
                           "text"=>"To valued user you have recently requested a password reset,\n      here is your reset url, please enter it into your browser: http://127.0.0.1:9393/users/reset/RESET_TOKEN",
                           "to"=>"khushkaran@me.com"},
                 :headers => {'Accept'=>'*/*; q=0.5, application/xml',
                              'Accept-Encoding'=>'gzip, deflate',
                              'Content-Type'=>'application/x-www-form-urlencoded',
                              'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "", :headers => {})
  end

  scenario "can login with a reset password " do
    visit "/users/reset/RESET_TOKEN"
    fill_in 'password', with: 'test1'
    fill_in 'password_confirmation', with: 'test1'
    click_button 'Submit'
    sign_in('khushkaran@me.com','test1')
    expect(page).to have_content("Welcome, ")
  end
end