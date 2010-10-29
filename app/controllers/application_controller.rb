class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user, :logged_in?
  
  def login_required
    if !current_user
      return true
    end
    flash[:warning] = 'Login required'
    redirect_to :controller => 'user', :action => 'login'
  end
  
  def current_user
    @_current_user ||= session[:current_user_id] && User.find(session[:current_user_id])
  end
  
  def logged_in?
    !current_user.nil?
  end
end
