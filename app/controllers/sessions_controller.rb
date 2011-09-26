require 'rest_client'

class SessionsController < ApplicationController

  before_filter :only => :create do
    RubyCAS::Filter.filter(self) if params[:cas]
  end

  def create
    session[:form_username] = params[:username]
    begin
      @new_session = if params[:cas]
        proxy_granting_ticket = session[:cas_pgt]
        Rails.logger.info "PGT: " + proxy_granting_ticket.inspect
        proxy_ticket = RubyCAS::Filter.client.request_proxy_ticket(
                         proxy_granting_ticket, APP_CONFIG.asi_url
                       ).ticket
        Rails.logger.info "PT: " + proxy_ticket.inspect
        Session.create({ :username => session[:cas_user],
                         :proxy_ticket => proxy_ticket },
                       cas_session_url(:consent_ok => '1'),
                       page_url(:login_failed) )
        # TODO: add login_failed page and handle consent_ok
      else
        Session.create({ :username => params[:username],
                         :password => params[:password] })
      end

    rescue Session::NewUserRedirect => e
      # redirect to consent form page
      redirect_to e.url and return
    rescue RestClient::Unauthorized => e
      flash[:error] = _("Login failed")
      redirect_to :controller => "sessions", :action => "index" and return
    end

    session[:form_username] = nil

    if @new_session.person_id  # if not app-only-session and person found in ASI
      # Find user record from local database. In not found, create a new record
      user = User.find_by_asi_id(@new_session.person_id) ||
             User.create(:asi_id => @new_session.person_id)
      session[:current_user_id] = user.id
    end
    
    session[:cookie] = @new_session.cookie
    session[:person_id] = @new_session.person_id

    flash[:notice] = _("Login successful")

    # Redirect to return_to using the user's preferred locale
    #
    # return_to is passed as an URL. That and the way HTTP 30x redirects work
    # have the effect of changing the HTTP method to GET, which effectively
    # converts potentially destructive actions to safe show or index actions
    # as long as no GET action does anything destructive without a redirect.
    return_to = params[:return_to].present? && begin
      uri = URI::parse(params[:return_to])
      if uri.host != request.host  # sanity check
        nil
      else
        # try to parse the URL to return to
        p = Rails.application.routes.recognize_path(params[:return_to])
        p.reverse_merge!(Rack::Utils.parse_query(uri.query))
        # don't redirect to login page
        p = nil if p[:controller] == 'sessions' && p[:action] == 'index'
        p
      end
    rescue
      nil
    end

    lang = current_user.andand.language || APP_CONFIG.fallback_locale
    if return_to
      redirect_to return_to.merge(:locale => lang)
    else
      redirect_to root_path(:locale => lang)
    end
  end
  
  def destroy
    Session.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:current_user_id] = nil
    session[:person_id] = nil
    flash[:notice] = _("Logout successful")
    redirect_to root_path
  end
  
  def index
    
  end
  
  def request_new_password
    begin
      RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people/recover_password", {:email => params[:email]}, {:cookies => Session.kassi_cookie})
      flash[:notice] = :password_recovery_sent
    rescue RestClient::ResourceNotFound => e 
      flash[:error] = :email_not_found
    end
    redirect_to new_session_path
  end
  
end
