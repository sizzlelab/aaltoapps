class PlatformsController < ApplicationController
  load_and_authorize_resource :except => :add_product

  # GET /platforms
  # GET /platforms
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @platforms }
    end
  end

  # GET /platforms/new
  # GET /platforms/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @platform }
    end
  end

  # GET /platforms/1
  # GET /platforms/1
  def show
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @platform }
    end
  end

  # GET /platforms/1/edit
  def edit
  end

  # POST /platforms
  # POST /platforms.xml
  def create
    if @platform.save
      respond_to do |format|
        format.html { redirect_to({:action => "show", :id => @platform.id}, :notice => _("Platform was successfully created"))}
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
    respond_to do |format|
      if @platform.update_attributes(params[:platform])
        format.html { redirect_to({:action => "show", :id => @platform.id}, :notice => _('Platform was successfully updated.')) }
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
    respond_to do |format|
      begin
        @platform.destroy
      rescue ActiveRecord::ActiveRecordError => e
        errmsg = if e.is_a? ActiveRecord::DeleteRestrictionError
          _('Cannot delete platform that has products')
        else
          e.to_s
        end

        format.html { redirect_to({:action => "index"}, :alert => errmsg) }
        format.xml  { render :xml => {:error => errmsg}.to_xml(:root => :errors), :status => :conflict }
      else
        format.html { redirect_to({:action => "index"}, :notice => _("Platform was successufully deleted.")) }
        format.xml  { head :ok }
      end
    end
  end

  def add_product
    product = Product.find(params[:id])
    platform = Platform.find(params[:product][:platform_ids])
    product.platforms << platform

    authorize! :add_platform, product

    product.save!
    redirect_to :back
  end
end
