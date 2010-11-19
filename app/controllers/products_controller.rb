class ProductsController < ApplicationController
  before_filter :login_required, :except => [:index, :show,:apps_by_platform,:apps_by_critea]
  before_filter :add_popularity, :only=>:show

  PRODUCTS_PER_PAGE = 6
  DEFAULT_SORT="updated_at DESC"
  ALLOWED_SORT_KEYS = %w(name created_at updated_at publisher average_rating)

  # GET /products
  # GET /products.xml
  def index
    page = params[:page] ? params[:page] : 1

    # check the existence and validity of the sort parameter
    # and if nonexistent or invalid, use default value
    find_params =
      if  params[:sort] &&
          params[:sort] =~ /^([a-z_]+)(?: +DESC)?$/i &&
          ALLOWED_SORT_KEYS.member?($1)
        if $1 == 'average_rating'
          # TODO: implement this
          #{ :include=>[:ratings], :order=>'ratings.rating' }
          {}
        else
          { :order => params[:sort] }
        end
      else
        { :order => DEFAULT_SORT }
      end

    @products = Product.paginate({ :page => page, :per_page => PRODUCTS_PER_PAGE }.merge(find_params))

    my_published_apps_by("all platforms")
    #find_apps_by("all platforms")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end
  
  def by_platform
    sort_by_platform_and_criteria(params[:platform])
    render :action=>:index
  end

  def sort_by_platform_and_criteria(platform,criteria=DEFAULT_SORT)
     if platform=="all platforms"
       @products=Product.order(criteria)
    else
        @products=Product.sort_apps_by(platform,criteria)     
      end
     @my_published_products=my_published_apps_by(platform,criteria)
  end

  def search
    if params[:search]&&!params[:search].blank?
      @products=Product.where("name LIKE ?","%#{params[:search]}%")
      if @products.blank?
      @err_msg="The keywords you search don't exist!"
      end
    else
      @err_msg="Your should input some keywords!"
    end

    render :action=>:index
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    # Create a new Rating for the product copying the value of the
    # current user's current rating, if any.
    if logged_in?
      @new_rating_for_current_user = @product.ratings.build(
        :rating => @product.ratings.find_by_user_id(current_user.id) || ''
      )
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])
    @product.publisher_id = current_user.id
 if params[:cancel]
   @product = Product.new
   render :action=>'new'
 else
    respond_to do |format|
      if @product.save        
	format.html { redirect_to(@product, :notice => 'Product was successfully created.') }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to(@product, :notice => 'Product was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end
  private
  def add_popularity
    @product = Product.find(params[:id])
    @product.popularity+=1
    @product.save
  end
 
  #return apps that user created by platform
  def my_published_apps_by(platform,criteria=DEFAULT_SORT)
  #If user login, show himself's apps
     @my_published_products=[]
    if current_user!=nil
      if platform=="all platforms"
        @my_published_products=current_user.published.order(criteria)
      else
        current_user.published.order(criteria).where("platform=?","#{platform}")
     
      end
    end
  end

end
