require 'spec_helper'

describe RatingsController do

  fixtures :users, :sessions, :products, :categories, :platforms

  before(:each) do
    @current_user_id = session[:current_user_id] = users(:aaltoappstest1).id
    @referrer_url = request.env["HTTP_REFERER"] = url = "http://test.url.invalid/path"
  end

  describe "POST create" do

    describe "with valid params" do
      before(:each) do
        post :create, :rating => {:rating => Rating::MIN.to_s}, :product_id => products(:product1).id, :locale => "en"
      end

      it "assigns a newly created rating as @rating" do
        assigns(:rating).should be_valid
        assigns(:rating).rating.should eql(Rating::MIN.to_f)
        assigns(:rating).product_id.should eql(products(:product1).id)
        assigns(:rating).user_id.should eql(@current_user_id)
      end

      it "redirects to the page it got as referrer" do
        response.should redirect_to(@referrer_url)
      end
    end

    describe "with an invalid value" do
      before(:each) do
        post :create, :rating => {:rating => (Rating::MAX+1).to_s}, :product_id => products(:product1).id, :locale => "en"
      end

      it "assigns a newly created but unsaved rating as @rating" do
        assigns(:rating).product_id.should eql(products(:product1).id)
        assigns(:rating).user_id.should eql(@current_user_id)
      end

      it "redirects to the page it got as referrer" do
        response.should redirect_to(@referrer_url)
      end

      it "displays an error message" do
        flash[:alert].should_not be_empty
      end
    end

    describe "with a nonexistent product" do
      before(:each) do
        post :create, :rating => {:rating => Rating::MIN.to_s}, :product_id => -1, :locale => "en"
      end

      it "redirects to the page it got as referrer" do
        response.should redirect_to(@referrer_url)
      end

      it "displays an error message" do
        flash[:alert].should_not be_empty
      end
    end

    describe "with no user logged in" do
      before(:each) do
        session.delete(:current_user_id)
        post :create, :rating => {:rating => Rating::MIN.to_s}, :product_id => products(:product1).id, :locale => "en"
      end

      it "assigns a newly created but unsaved rating as @rating" do
        assigns(:rating).should_not be_valid
      end

      it "redirects to the page it got as referrer" do
        response.should redirect_to(@referrer_url)
      end

      it "displays an error message" do
        flash[:alert].should_not be_empty
      end
    end

  end

end
