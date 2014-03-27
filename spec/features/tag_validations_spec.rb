require 'spec_helper'

feature "Tag fails to satisfy validations" do
  scenario "Tag must have some text" do
    lambda {Tag.first_or_create(:text => '', :user_id => 1)}.should change(Tag, :count).by(0)
  end
end