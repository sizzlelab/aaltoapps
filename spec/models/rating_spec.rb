require 'spec_helper'

describe Rating do

  before(:each) do
    # create an initially valid rating instance
    # use dummy values for user and product ids
    @rating = Rating.new(:user_id => 0xdead, :product_id => 0xbeef, :rating => Rating::Max)
  end
  
  it "should accept all valid values" do
    Rating.allowed_values.each do |value|
      @rating.rating = value
      @rating.should be_valid
    end
  end
  
  it "should not accept invalid values" do
    [ Rating::Min - 1,
      Rating::Min + Rating::Increment*0.5,
      Rating::Max - Rating::Increment*0.5,
      Rating::Max + 1
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
    @rating.user_id = nil
    @rating.should_not be_valid
  end

  it "should not accept empty product" do
    @rating.product_id = nil
    @rating.should_not be_valid
  end

end
