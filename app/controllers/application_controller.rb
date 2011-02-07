class ApplicationController < ActionController::Base
  protect_from_forgery
  include FastGettext::Translation
  before_filter :set_locale
  helper_method :current_user, :logged_in?, :products_by_platform_path

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/403.html",
                           :layout => false,
                           :status => :forbidden }
      format.xml  { head :forbidden }
    end
  end

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
    FastGettext.available_locales = I18n.available_locales

    if params[:locale]

      I18n.locale = FastGettext.set_locale(params['locale'])

      # make a sorted list of available locales and their associated information
      @available_locales = FastGettext.available_locales.map do |locale|
        {
          :id => locale,
          # get the native language name by reading a special
          # I18n-style translation string, which contains the name
          :name => I18n.translate('i18n.language.name', :locale => locale),
          :current? => (locale.to_s == I18n.locale.to_s),
        }
      end
      @available_locales.sort! { |a, b| a[:name].casecmp(b[:name]) }

    elsif request.fullpath == '/'
      # redirect main page url without a locale string
      # to an url with a proper locale string
      locale = FastGettext.best_locale_in(request.env['HTTP_ACCEPT_LANGUAGE']) || 'en'
      redirect_to("/#{locale}")
    else
      raise ActionController::RoutingError.new('No locale in path')
    end
  end
end
