module ApplicationHelper
  def current_user
    session[:user]
  end
  
  def logged_in?
    !current_user.nil?
  end
end
