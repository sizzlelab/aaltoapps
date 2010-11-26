require 'spec_helper'

describe RatingsController do

  def mock_rating(stubs={})
    (@mock_rating ||= mock_model(Rating).as_null_object).tap do |rating|
      rating.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all ratings as @ratings" do
      Rating.stub(:all) { [mock_rating] }
      get :index
      assigns(:ratings).should eq([mock_rating])
    end
  end

  describe "GET show" do
    it "assigns the requested rating as @rating" do
      Rating.stub(:find).with("37") { mock_rating }
      get :show, :id => "37"
      assigns(:rating).should be(mock_rating)
    end
  end

  describe "GET new" do
    it "assigns a new rating as @rating" do
      Rating.stub(:new) { mock_rating }
      get :new
      assigns(:rating).should be(mock_rating)
    end
  end

  describe "GET edit" do
    it "assigns the requested rating as @rating" do
      Rating.stub(:find).with("37") { mock_rating }
      get :edit, :id => "37"
      assigns(:rating).should be(mock_rating)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created rating as @rating" do
        Rating.stub(:new).with({'these' => 'params'}) { mock_rating(:save => true) }
        post :create, :rating => {'these' => 'params'}
        assigns(:rating).should be(mock_rating)
      end

      it "redirects to the created rating" do
        Rating.stub(:new) { mock_rating(:save => true) }
        post :create, :rating => {}
        response.should redirect_to(rating_url(mock_rating))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved rating as @rating" do
        Rating.stub(:new).with({'these' => 'params'}) { mock_rating(:save => false) }
        post :create, :rating => {'these' => 'params'}
        assigns(:rating).should be(mock_rating)
      end

      it "re-renders the 'new' template" do
        Rating.stub(:new) { mock_rating(:save => false) }
        post :create, :rating => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested rating" do
        Rating.should_receive(:find).with("37") { mock_rating }
        mock_rating.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :rating => {'these' => 'params'}
      end

      it "assigns the requested rating as @rating" do
        Rating.stub(:find) { mock_rating(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:rating).should be(mock_rating)
      end

      it "redirects to the rating" do
        Rating.stub(:find) { mock_rating(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(rating_url(mock_rating))
      end
    end

    describe "with invalid params" do
      it "assigns the rating as @rating" do
        Rating.stub(:find) { mock_rating(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:rating).should be(mock_rating)
      end

      it "re-renders the 'edit' template" do
        Rating.stub(:find) { mock_rating(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested rating" do
      Rating.should_receive(:find).with("37") { mock_rating }
      mock_rating.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the ratings list" do
      Rating.stub(:find) { mock_rating }
      delete :destroy, :id => "1"
      response.should redirect_to(ratings_url)
    end
  end

end
