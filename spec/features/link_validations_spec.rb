require 'spec_helper'
require_relative 'helpers/link'

include LinkHelpers

feature "Link fails to satisfy validations" do
  scenario "Link must have a title" do
    lambda {add_link("http://www.makersacademy.com/", "")}.should change(Link, :count).by(0)
  end

  scenario "Link must have a URL" do
    lambda {add_link("", "Makers Academy")}.should change(Link, :count).by(0)
  end
end