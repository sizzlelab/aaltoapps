require 'spec_helper'

describe Category do
  before (:each) do
    @category = Category.new :name => "my category", :image_url => "http://images.com/foo.png"
    @category.should be_valid
  end

  it "should not have a nil name" do
    @category.name = nil
    @category.should_not be_valid
  end

  it "should not have a too short name" do
    @category.name = "!"
    @category.should_not be_valid
  end
end

