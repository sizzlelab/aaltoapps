class ProductsController < ApplicationController
  load_and_authorize_resource :only => [:index, :show, :new, :edit, :create, :update, :destroy, :block, :approve]
  before_filter :add_popularity, :only=>:show

  PRODUCTS_PER_PAGE = 6
  DEFAULT_SORT = "products.created_at DESC"
  ALLOWED_SORT_KEYS = %w(name created_at updated_at publisher avg_rating featured popularity) 

  # GET /products
  # GET /products.xml
  def index
		if params[:approval] && current_user.is_admin?
			@products = @products.where(:is_approved)
			respond_to do |format|
				format.html { render_template :template => "products/approval" }
				format.xml { render :xml => @products }
			end
		else
			page = params[:page] ? params[:page].to_i : 1
			@products = @products.joins(:platforms).
				where(:platforms => {:id => params[:platform_id].to_i}) if params[:platform_id]
      if params[:myapps]
        @products = @products.where(:publisher_id => current_user.id)
      else
        @products = @products.where(:is_approved)
      end
			@products = @products.where("name ILIKE :input", {:input => "%#{params[:q]}%"}) if params[:q]
			@products = @products.order(order_parameter(params[:sort]))

			@products = @products.all.paginate(:page => page,
																				 :per_page => PRODUCTS_PER_PAGE)

    	respond_to do |format|
      	format.html # index.html.erb
      	format.xml  { render :xml => @products }
    	end
		end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    # Create a new Rating for the product copying the value of the
    # current user's current rating, if any.
    if logged_in?
      @new_rating_for_current_user = @product.ratings.build(
        :rating => @product.ratings.find_by_user_id(current_user.id) || nil
      )
    end

    @comments = @product.comments.accessible_by(current_ability)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.xml
  def create
    @product.publisher_id = current_user.id
		if params[:cancel]
      @product = Product.new
      render :action => 'new'
    else
      respond_to do |format|
        if @product.save        
          format.html { redirect_to(@product, :notice => _('Product was successfully created.')) }
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
    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to(@product, :notice => _('Product was successfully updated.')) }
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
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end

	def approve
		@product.change_approval true
		redirect_to :back
	end

	def block
		@product.change_approval false
		redirect_to :back	
	end

  private

  def add_popularity
    @product = Product.find(params[:id])
    @product.popularity += 1
    @product.save
  end

  def order_parameter(get_param)
    return DEFAULT_SORT if !get_param

    case get_param
    when 'popularity'
      sort = 'popularity DESC'
    when 'created_at'
      sort = 'created_at DESC'
    when 'avg_rating'
      sort = 'avg_rating IS NULL ASC, avg_rating DESC'
    when 'featured'
      sort = 'featured DESC'
    else
      sort = DEFAULT_SORT
    end

    return sort
  end

	def require_admin
		return if current_user && current_user.is_admin?
		redirect_to root_path
	end

end
