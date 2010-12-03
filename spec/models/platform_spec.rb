require 'spec_helper'

describe Platform do
  before (:each) do
    @platform = Platform.new :name => "my platform", :image_url => "http://images.com/foo.png"
    @platform.should be_valid
  end

  it "should not have a nil name" do
    @platform.name = nil
    @platform.should_not be_valid
  end

  it "should not have a too short name" do
    @platform.name = "!"
    @platform.should_not be_valid
  end
end

