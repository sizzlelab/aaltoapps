class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def login_required
    if !current_user
      return true
    end
    flash[:warning] = 'Login required'
    redirect_to :controller => 'user', :action => 'login'
  end
  
  def current_user
    session[:user]
  end
  
  def logged_in?
    !session[:user].nil?
  end
end
