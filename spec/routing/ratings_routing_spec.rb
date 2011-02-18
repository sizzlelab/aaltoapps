require "spec_helper"

describe RatingsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/ratings" }.should route_to(:controller => "ratings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/ratings/new" }.should route_to(:controller => "ratings", :action => "new")
    end
  end
end
