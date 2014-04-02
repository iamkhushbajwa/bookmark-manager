require 'spec_helper'

describe Link do
  context "Demonstration of how datamapper works" do
    it "should be created and then retreived from the db" do
      link_count = Link.count 
      expect(Link.count).to eq(link_count)
      Link.create(:title => "Makers Academy", :url => "http://www.makersacademy.com/")
      expect(Link.count).to eq(link_count+1)
      link = Link.first(:title => "Makers Academy")
      expect(link.url).to eq("http://www.makersacademy.com/")
      expect(link.title).to eq("Makers Academy")
      link.destroy
      expect(Link.count).to eql(link_count)
    end
  end
end