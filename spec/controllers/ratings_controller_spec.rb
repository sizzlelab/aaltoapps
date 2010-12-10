require 'spec_helper'

describe RatingsController do

  fixtures :users, :sessions

  before(:each) do
    @current_user_id = session[:current_user_id] = users(:aaltoappstest1).id
    @referrer_url = request.env["HTTP_REFERER"] = url = "http://test.url.invalid/path"
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created rating as @rating" do
        post :create, :rating => {:rating => Rating::MIN.to_s}, :product_id => 0xbeef
        assigns(:rating).rating.should eql(Rating::MIN.to_f)
        assigns(:rating).product_id.should eql(0xbeef)
        assigns(:rating).user_id.should eql(@current_user_id)
      end

      it "redirects to the page it got as referrer" do
        post :create, :rating => {:rating => Rating::MIN.to_s}, :product_id => 0xbeef
        response.should redirect_to(@referrer_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rating as @rating" do
        post :create, :rating => {:rating => (Rating::MIN-1).to_s}, :product_id => 0xbeef
        assigns(:rating).product_id.should eql(0xbeef)
        assigns(:rating).user_id.should eql(@current_user_id)
      end

      it "redirects to the page it got as referrer" do
        post :create, :rating => {:rating => (Rating::MIN-1).to_s}, :product_id => 0xbeef
        response.should redirect_to(@referrer_url)
      end

      it "displays an error message"
    end

  end

end
