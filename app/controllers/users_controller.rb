class UsersController < ApplicationController
  load_and_authorize_resource :except => [:index, :create, :terms]

  # GET /users
  # GET /users.xml
  def index
    if params[:all].present?
      authorize! :asi_index, User
      @users = User.asi_find(params.except(:all))
    else
      authorize! :index, User
      @users = User.accessible_by(current_ability)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.xml
  def create
    authorize! :create, User
    @new_session = Session.create
    session[:cookie] = @new_session.cookie
    @user = User.new(params[:user].merge(:asi_cookie => @new_session.cookie))
    authorize! :grant_admin_role, @user if @user.is_admin?
    begin
      @user.save!
    rescue ActiveRecord::RecordInvalid
      render :action => "new" and return
    rescue RestClient::RequestFailed => e
      flash.now[:error] = JSON.parse(e.response.body)["messages"]
      render :action => "new" and return
    end

    session[:current_user_id] = @user.id

    respond_to do |format|
      format.html { redirect_to(@user, :notice => _("Logged in")) }
      format.xml  { render :xml => @user, :status => :created, :location => @user }
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    # if admin status changes, check authorization for the change
    if params[:user].has_key?(:is_admin)
      was_admin = @user.is_admin?
      @user.is_admin = params[:user].delete :is_admin
      authorize! :grant_admin_role, @user if !was_admin && @user.is_admin?
      authorize! :revoke_admin_role, @user if was_admin && !@user.is_admin?
    end

    if params[:user].has_key?(:receive_admin_email)
      prev_val = @user.receive_admin_email
      @user.receive_admin_email = params[:user].delete :receive_admin_email
      authorize! :set_receive_admin_email, @user if !prev_val && @user.receive_admin_email
      authorize! :unset_receive_admin_email, @user if prev_val && !@user.receive_admin_email
    end

    @user.asi_cookie = session[:cookie]
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(:back, :notice => _('User was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def terms
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'terms'
        else
          render :inline => '<%= render :partial => "terms" %>', :layout => true
        end
      end
    end
  end
end
