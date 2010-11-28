class ProductsController < ApplicationController
  before_filter :login_required, :except => [:index, :show,:apps_by_platform,:apps_by_critea]
  before_filter :add_popularity, :only=>:show

  PRODUCTS_PER_PAGE = 6
  DEFAULT_SORT = "products.created_at DESC"
  ALLOWED_SORT_KEYS = %w(name created_at updated_at publisher avg_rating featured) 
  # GET /products
  # GET /products.xml
  def index
    page = params[:page] ? params[:page].to_i : 1

    # check the existence and validity of the sort parameter
    # and if nonexistent or invalid, use default value
    sort =
      if  params[:sort] &&
          params[:sort] =~ /^ *([a-z_]+) *( (?:ASC|DESC))? *$/i &&
          ALLOWED_SORT_KEYS.member?($1)
        case $1
        when 'popularity', 'created_at', 'updated_at', 'avg_rating','featured'
          # these are sorted in descending order by default
          'products.' + $1 + ($2 || ' DESC')
        else
          # everything else is sorted in ascending order by default
          'products.' + $1 + ($2 || ' ASC')
        end
      else
        DEFAULT_SORT
      end

    catch(:abort) do
      query = Product
      if params[:q]
        if params[:q].empty?
          flash[:alert] = _('Empty search string')
          throw :abort
        end
        query = query.where("name LIKE ?", "%#{params[:q]}%")
      end
      query = query.where(:platform_id => params[:platform]) if params[:platform]

      @products = query.paginate(:page => page, :per_page => PRODUCTS_PER_PAGE, :order => sort)

      @my_published_products = my_published_apps_by(params[:platform], sort)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
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
      render :action => 'new'
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
    @product.popularity += 1
    @product.save
  end

  #return apps that user created by platform
  def my_published_apps_by(platform_id, sort=DEFAULT_SORT)
    # If user logged in, show his/her apps
    if logged_in?
      if platform_id
        current_user.published.order(sort).where(:platform_id => platform_id)
       else
        current_user.published.order(sort)
       end
    else
      []
     end
  end

end
