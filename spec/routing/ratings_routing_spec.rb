require "spec_helper"

describe RatingsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/ratings" }.should route_to(:controller => "ratings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/ratings/new" }.should route_to(:controller => "ratings", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/ratings/1" }.should route_to(:controller => "ratings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/ratings/1/edit" }.should route_to(:controller => "ratings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/ratings" }.should route_to(:controller => "ratings", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/ratings/1" }.should route_to(:controller => "ratings", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/ratings/1" }.should route_to(:controller => "ratings", :action => "destroy", :id => "1")
    end

  end
end
