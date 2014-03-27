require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "Favourites" do
  scenario "User favourites a link" do
    User.create(:username => 'test', :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
    Link.create(:url => "http://www.google.com", :title => "Google", :tags => [Tag.first_or_create(:text => 'search')], :user_id => 1)
    sign_in('test@test.com', 'test')
    user = User.first
    visit '/'
    click_button 'Favourite Google'
    expect(user.links.map(&:title)).to include("Google")
    expect(page).to have_content("1 added yesterday by ")
  end

  scenario "Users can see their link, tags & favourites" do
    User.create(:id => 1, :username => 'test', :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
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