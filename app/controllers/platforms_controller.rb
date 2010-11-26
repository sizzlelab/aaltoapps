class PlatformsController < ApplicationController
  before_filter :login_required

  # GET /platforms
  # GET /platforms
  def index
    @platforms = Platform.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @platforms }
    end
  end

  # GET /platforms/new
  # GET /platforms/new.xml
  def new
    @platform = Platform.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @platform }
    end
  end

  # GET /platforms/1
  # GET /platforms/1
  def show
    @platform = Platform.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @platform }
    end
  end

  # GET /platforms/1/edit
  def edit
    @platform = Platform.find(params[:id])
  end

  # POST /platforms
  # POST /platforms.xml
  def create
    @platform = Platform.new(params[:platform])
    
    if @platform.save
      respond_to do |format|
        format.html { redirect_to :action => "show", :id => @platform.id, :notice => _("Platform was successfully created")}
        format.xml { render :xml => @platform, :status => :created, :location => @loatform}
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml { render :xml => @platform.errors, :status => :unprocessable_entity}
      end
    end
  end

  # PUT /platforms/1
  # PUT /platforms/1.xml
  def update
    @platform = Platform.find(params[:id])

    respond_to do |format|
      if @platform.update_attributes(params[:platform])
        format.html { redirect_to(:action => "show", :id => @platform.id, :notice => _('Platform was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @platform.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /platforms/1
  # DELETE /platforms/1.xml
  def destroy
    @platform = Platform.find(params[:id])
    @platform.destroy

    respond_to do |format|
      format.html { redirect_to(:action => "index", :notice => _("Platform was successufully deleted.")) }
      format.xml  { head :ok }
    end
  end
end
