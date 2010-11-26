require 'spec_helper'

describe Comment do
  before(:each) do
    @comment = Comment.new :body => "comment body", :product_id => 0xcafe, :commenter_id => 0xbabe
    @comment.should be_valid
  end

  it "should not have a nil body" do
    @comment.body = nil
    @comment.should_not be_valid
  end

  it "should not have a too short body" do
    @comment.body = "!"
    @comment.should_not be_valid 
  end

  it "should not have a nil commenter" do
    @comment.commenter = nil
    @comment.should_not be_valid
  end

  it "should not have a nil product" do
    @comment.product = nil
    @comment.should_not be_valid
  end

end

