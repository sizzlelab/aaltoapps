class UsersController < ApplicationController
  before_filter :login_required, :except => [:destroy, :update, :edit, :login]

  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/login
  # GET /users/login.xml
  def login
    if request.post?
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
    elsif logged_in?
      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.xml { render :xml => @user }
      end
    end
  end

  # GET /users/logout
  # GET /users/logout.xml
  def logout
    session[:current_user_id] = nil
    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok}
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
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
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
