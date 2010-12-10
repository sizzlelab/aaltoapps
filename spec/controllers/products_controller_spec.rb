require 'spec_helper'

describe ProductsController do

  def mock_product(stubs={})
    (@mock_product ||= mock_model(Product).as_null_object).tap do |o|
      o.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    @products_controller = ProductsController.new
  end

  it "should desc" do
    # TODO
  end
end
