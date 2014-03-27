require 'spec_helper'
require_relative 'helpers/link'
require_relative 'helpers/session'
require_relative 'helpers/http_stub'

include SessionHelpers
include LinkHelpers
include HttpHelpers

feature 'User browses the list of links' do
  before(:each){
    from = "admin@bookmark-manager.com"
    title = "Welcome to Bookmark Manager"
    text = "Dear User, we would like to welcome you to Bookmark Manager, a place to share your favourite links with the world. Now you have signed up the world can see what links you have contributed and you can like links!"
    to = "alice@example.com"
    stub_http(from, title, text,to)
    sign_up
    add_link("http://www.lse.ac.uk", "London School of Economics", ['education','finance','economics'])
    add_link("http://www.google.com", "Google", ['search'])
    add_link("http://www.bing.com", "Bing", ['search'])
    add_link("http://www.code.org", "Code.org", ['education'])
  }

  scenario "When opening the home page" do
    visit '/'
    expect(page).to have_content("London School of Economics")
  end

  scenario "filtered by a tag regardless of case" do
    visit '/tags/Search'
    expect(page).not_to have_content("London School of Economics")
    expect(page).not_to have_content("Code.org")
    expect(page).to have_content("Google")
    expect(page).to have_content("Bing")
  end

  scenario "Username is visible as the creator of a link" do
    visit '/'
    expect(page).to have_content(" by alice")
  end

  scenario "Tags are visible underneath the link" do
    visit '/'
    expect(page).to have_content("Education Finance Economics")
  end
end