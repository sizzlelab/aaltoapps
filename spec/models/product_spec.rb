require 'spec_helper'

describe Product do

  before(:each) do
    @publisher = User.new :asi_id => "12345"
    @publisher.should be_valid
    @platform = Platform.new :name => "plattis", :image_url => "http://foo.com/image.jpeg"
    @platform.should be_valid
    @category = Category.new :name => "category", :image_url => "http://category.com/category.png"
    @category.should be_valid
    @product = Product.new :name => "my product", :url => "http://foo.bar", :description => "the description has to be pretty long", :platforms => [@platform], :category => @category, :publisher => @publisher
    @product.should be_valid
  end

  it "should not have nil name" do
    @product.name = nil
    @product.should_not be_valid
  end

  it "should not have a too short name" do
    @product.name = "!"
    @product.should_not be_valid
  end

  it "should not have a nil url" do
    @product.url = nil
    @product.should_not be_valid
  end

  it "should not have a too short url" do
    @product.url = "!"
    @product.should_not be_valid
  end

  it "should not have a nil description" do
    @product.description = nil
    @product.should_not be_valid
  end

  it "should not have a nil category" do
    @product.category = nil
    @product.should_not be_valid
  end
end

