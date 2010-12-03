require 'spec_helper'

describe User do

  before (:each) do
    @user = User.new :asi_id => "12345"
    @user.should be_valid
  end

  it "should not have a nil ASI id" do
    @user.asi_id = nil
    @user.should_not be_valid
  end
end
