require 'asi_session'
class UsersController < ApplicationController
  #before_filter :login_required, :except => [:new, :create]

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
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    begin
      response = AsiSession.new.register(:username => params[:username], 
                                         :password => params[:password], 
                                         :email => params[:email], 
                                         :is_association => false, 
                                         :consent => params[:consent])
      @user = User.create!(:asi_id => JSON.parse(response)["entry"]["id"])
    rescue Exception => e
      flash.now[:error] = JSON.parse(e.message)["messages"]

      render :action => "new" and return
    end
    
    respond_to do |format|
      format.html { redirect_to(@user, :notice => 'User was successfully created.') }
      format.xml  { render :xml => @user, :status => :created, :location => @user }
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
