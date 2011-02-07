class CategoriesController < ApplicationController
  load_and_authorize_resource

  # GET /products
  # GET /products.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end
  
  # GET /products/new
  # GET /products/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end
  
  # GET /products/1/edit
  def edit
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end
 
  # POST /products
  # POST /products.xml
  def create
    respond_to do |format|
      if @category.save        
        format.html { redirect_to(:action => "show", :id => @category.id, :notice => _('Category was successfully created.')) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
     end
   end
  
   # PUT /products/1
   # PUT /products/1.xml
   def update
     respond_to do |format|
       if @category.update_attributes(params[:category])
         format.html { redirect_to(:action => "edit", :id => @category.id, :notice => _('Category was successfully updated.')) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
       end
     end
   end
  
   # DELETE /products/1
   # DELETE /products/1.xml
   def destroy
     @category.destroy
  
     respond_to do |format|
       format.html { redirect_to :action => "index" }
       format.xml  { head :ok }
     end
   end
end
