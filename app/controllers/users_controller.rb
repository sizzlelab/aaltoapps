class UsersController < ApplicationController
  load_and_authorize_resource :except => :create

  # GET /users
  # GET /users.xml
  def index
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
    #check user accpet the term
    if params[:user][:term]==0
      flash.now[:error]='In order to register, you must accept the OtaSizzle "Terms and Conditions".'
      render :action => "new" and return
    end
    authorize! :create, User
    @session = Session.create
    session[:cookie] = @session.cookie
    begin
      @user = User.create_to_asi(params[:user], session[:cookie]) 
    rescue RestClient::RequestFailed => e
      flash.now[:error] = JSON.parse(e.response.body)["messages"]
      @user = User.new  
      render :action => "new" and return
    end

    authorize! :grant_admin_role, @user if @user.is_admin?

    session[:user_id] = @user.id

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
      @user.is_admin = params[:user][:is_admin]
      authorize! :grant_admin_role, @user if !was_admin && @user.is_admin?
      authorize! :revoke_admin_role, @user if was_admin && !@user.is_admin?
    end

    respond_to do |format|
      if @user.update_attributes(params[:user], session[:cookie])
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
end
