require 'spec_helper'

describe "ratings/show.html.erb" do
  before(:each) do
    @rating = assign(:rating, stub_model(Rating,
      :rating => 1.5,
      :user_id => "",
      :product_id => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1.5/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(//)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
