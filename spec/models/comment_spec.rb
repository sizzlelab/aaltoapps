require 'spec_helper'

describe Comment do
  before(:each) do
    @publisher_and_commenter = User.new :asi_id => "12345"
    @publisher_and_commenter.should be_valid
    @platform = Platform.new :name => "plattis", :image_url => "http://foo.com/image.jpeg"
    @platform.should be_valid
    @category = Category.new :name => "category", :image_url => "http://category.com/category.png"
    @category.should be_valid
    @product = Product.new :name => "my product", :url => "http://foo.bar", :description => "the description has to be pretty long", :donate => "no thanks", :platforms => [@platform], :category => @category, :publisher => @publisher_and_commenter
    @product.should be_valid
    @comment = Comment.new :body => "comment body", :product => @product, :commenter => @publisher_and_commenter
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

