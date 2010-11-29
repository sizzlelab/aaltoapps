class ApplicationController < ActionController::Base
  protect_from_forgery
  include FastGettext::Translation
  before_filter :set_locale  
  helper_method :current_user, :logged_in?, :products_by_platform_path 
  
  def login_required
    if !logged_in?
      flash[:warning] = 'Login required'
      redirect_to :controller => 'users', :action => 'login'
    end
  end
  
  def current_user
    @_current_user ||= session[:current_user_id] && User.find(session[:current_user_id])
  end
  
  def logged_in?
    !current_user.nil?
  end

  # returns product list path for given platform and sort key
  # either or both of which can be nil
  def products_by_platform_path(platform, sort=nil)
    if platform.nil?
      products_path :sort => sort
    else
      platform_products_path platform, :sort => sort
    end
  end


protected
  
  def set_locale
    FastGettext.available_locales = ['en']
    FastGettext.text_domain = 'frontend'
    session[:locale] = I18n.locale = FastGettext.set_locale(params[:locale] || session[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
  end
end
