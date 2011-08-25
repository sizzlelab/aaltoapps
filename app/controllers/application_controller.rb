class ApplicationController < ActionController::Base
  protect_from_forgery
  include FastGettext::Translation
  before_filter :set_mobile_device, :set_locale
  helper_method :current_user, :logged_in?, :mobile_device?
  layout :select_layout

  # exception that controllers can raise to show the 404 error page
  class PageNotFound < StandardError; end

  rescue_from( ActionController::RoutingError,
               ActionController::UnknownController,
               ActionController::UnknownAction,
               ActiveRecord::RecordNotFound,
               PageNotFound
             ) { |e| render_error_page e, 404 }
  rescue_from(CanCan::AccessDenied) { |e| render_error_page e, 403 }

  def current_user
    @_current_user ||= session[:current_user_id] && User.find(session[:current_user_id])
  end
  
  def logged_in?
    !current_user.nil?
  end

  def mobile_device?
    # TODO: better mobile device detection
    session[:mobile_device] || request.user_agent =~ /Mobile|webOS|\bMIDP|Windows CE\b/
  end

protected

  def select_layout
    mobile_device? ? 'mobile_application' : 'application'
  end

  def set_mobile_device
    session[:mobile_device] = parse_boolean(params[:mobile]) if params.has_key?(:mobile)
    Rails.logger.debug "User-Agent: #{request.user_agent}"
    Rails.logger.debug "  (mobile_device? = #{mobile_device? ? 'true' : 'false'})" unless params.has_key?(:mobile)
  end

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
      locale = FastGettext.best_locale_in(request.env['HTTP_ACCEPT_LANGUAGE']) || APP_CONFIG.fallback_locale || 'en'
      redirect_to("/#{locale}")
    else
      raise ActionController::RoutingError.new('No locale in path')
    end
  end

  def render_error_page(exception, errorcode)
    if request.format.nil?
      # unrecognized format (format.any below doesn't work in this case)
      render :text => "error #{errorcode}: #{exception.to_s}", :status => errorcode
    else
      respond_to do |format|
        format.html do
          @exception = exception
          render :layout => 'error',
                 :template => "errors/#{errorcode}",
                 :status => errorcode
        end
        format.any(:xml, :json) do
          render request.format.to_sym => {'error' => exception.to_s}, :status => errorcode
        end
        format.any do
          render :text => "error #{errorcode}: #{exception.to_s}", :status => errorcode
        end
      end
    end
  end

  def parse_boolean(val)
    val.present? && val.to_s !~ /^(?:false|f|no|n|off|0+)$/i
  end

end
