class SessionsController < ApplicationController
  # GET /sessions/
  def index
    if logged_in?
      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.xml { render :xml => @user }
      end
    end
  end
  
  # POST /sessions/
  # POST /users/login.xml
  def create
    @user = User.find_by_username(params[:username])
    if !@user
      flash[:error] = 'User not found'
      
      respond_to do |format|
        format.html # login.html.erb
        format.xml
      end
    else
      session[:current_user_id] = @user.id
      flash[:notice] = 'Logged in as user %{name}' % { :name => @user.username }
      
      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.xml { render :xml => @user}
      end
    end
  end

  # DELETE /sessions/
  # DELETE /sessions/destroy.xml
  def destroy
    session[:current_user_id] = nil
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok}
    end
  end
end