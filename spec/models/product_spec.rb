require 'spec_helper'

describe Product do

  before(:each) do
    # TODO: make platform and donate sane
    @product = Product.new :name => "my product", :url => "http://foo.bar", :description => "the description has to be pretty long", :donate => "no thanks", :platform_id => 0xf00d, :category_id => 0x1337 
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
    @product.name = "!"
    @product.should_not be_valid
  end

  it "should not have a nil description" do
    @product.description = nil
    @product.should_not be_valid
  end

  it "should not have a nil platform" do
    @product.platform = nil
    @product.should_not be_valid
  end

  it "should not have a nil category" do
    @product.category = nil
    @product.should_not be_valid
  end
end

