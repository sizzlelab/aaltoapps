require 'rest_client'

class SessionsController < ApplicationController  
  def create
    session[:form_username] = params[:username]
    begin
      @new_session = Session.create({ :username => params[:username],
                                      :password => params[:password] })
                                                          
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

    # redirect using user's preferred locale, if possible
    if session[:return_to]
      session[:return_to].merge!(:locale => current_user.language)  if session.is_a? Hash
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      redirect_to root_path(:locale => current_user.language)
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
