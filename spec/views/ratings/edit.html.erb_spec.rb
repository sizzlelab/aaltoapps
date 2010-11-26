require 'spec_helper'

describe "ratings/edit.html.erb" do
  before(:each) do
    @rating = assign(:rating, stub_model(Rating,
      :new_record? => false,
      :rating => 1.5,
      :user_id => "",
      :product_id => ""
    ))
  end

  it "renders the edit rating form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => rating_path(@rating), :method => "post" do
      assert_select "input#rating_rating", :name => "rating[rating]"
      assert_select "input#rating_user_id", :name => "rating[user_id]"
      assert_select "input#rating_product_id", :name => "rating[product_id]"
    end
  end
end
