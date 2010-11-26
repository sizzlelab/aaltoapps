require 'spec_helper'

describe "ratings/index.html.erb" do
  before(:each) do
    assign(:ratings, [
      stub_model(Rating,
        :rating => 1.5,
        :user_id => "",
        :product_id => ""
      ),
      stub_model(Rating,
        :rating => 1.5,
        :user_id => "",
        :product_id => ""
      )
    ])
  end

  it "renders a list of ratings" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
