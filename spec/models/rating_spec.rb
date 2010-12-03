require 'spec_helper'

describe Rating do

  before(:each) do
    @publisher_and_rater = User.new :asi_id => "12345"
    @publisher_and_rater.should be_valid
    @platform = Platform.new :name => "plattis", :image_url => "http://foo.com/image.jpeg"
    @platform.should be_valid
    @category = Category.new :name => "category", :image_url => "http://category.com/category.png"
    @category.should be_valid
    @product = Product.new :name => "my product", :url => "http://foo.bar", :description => "the description has to be pretty long", :donate => "no thanks", :platform => @platform, :category => @category, :publisher => @publisher_and_rater
    @product.should be_valid
    @rating = Rating.new(:user => @publisher_and_rater, :product => @product, :rating => Rating::MAX)
    @rating.should be_valid
  end
  
  it "should accept all valid values" do
    Rating.allowed_values.each do |value|
      @rating.rating = value
      @rating.should be_valid
    end
  end
  
  it "should not accept invalid values" do
    [ Rating::MIN - 1,
      Rating::MIN + Rating::STEP*0.5,
      Rating::MAX - Rating::STEP*0.5,
      Rating::MAX + 1
    ].each do |value|
      @rating.rating = value
      @rating.should_not be_valid
    end
  end
  
  it "should not accept nil as value" do
    @rating.rating = nil
    @rating.should_not be_valid
  end

  it "should not accept empty user" do
    @rating.user = nil
    @rating.should_not be_valid
  end

  it "should not accept empty product" do
    @rating.product = nil
    @rating.should_not be_valid
  end

end
