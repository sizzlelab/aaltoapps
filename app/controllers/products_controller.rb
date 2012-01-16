class ProductsController < ApplicationController
  load_and_authorize_resource(
    :only => [:index, :show, :new, :edit, :create, :update, :destroy,
              :block, :approve, :request_approval,
              :promote, :demote ] )
  before_filter :add_popularity, :only=>:show

  PRODUCTS_PER_PAGE = 6
  DEFAULT_SORT = "products.created_at DESC"
  DEFAULT_SORT_KEY = "created_at"
  ALLOWED_SORT_KEYS = %w(name created_at updated_at publisher avg_rating featured popularity)
  TAG_AUTOCOMPLETE_LIMIT = 20

private

  def fetch_data_for_index(params)
    page = params[:page] ? params[:page].to_i : 1

    if params[:platform_id]
      @platform = Platform.find(params[:platform_id])
      @products = @products.joins(:platforms).where(:platforms => {:id => @platform.id})
    end

    if params[:tags]
      @tags = ActsAsTaggableOn::TagList.from(params[:tags])
      @products = @products.tagged_with(params[:tags], :any => true)
    end

    if params[:myapps]
      @products = @products.where(:publisher_id => current_user.id)
      @view_type = :myapps
    elsif params[:approval]
      # this authorization might not be necessary; the results would be empty for normal users
      authorize! :approve, Product
      @approval_state = params[:approval]
      @products = @products.where(:approval_state => @approval_state)
      @view_type = :approval
    else
      @products = @products.where(:approval_state => 'published')
      @view_type = :index
    end

    if params[:q]
      # This SQL expression is database-specific. It works at least with
      # PostgreSQL. With SQLite it almost works: non-ascii characters are
      # compared case-sensitively.
      @products = @products.where(
        "lower(name) LIKE lower(:input) OR lower(description) LIKE lower(:input)",
        {:input => "%#{params[:q]}%"} )
      @search = params[:q]
    end

    @sort = params[:sort] || DEFAULT_SORT_KEY
    @products = @products.order(order_parameter(@sort))

    @products = @products.paginate(:page => page,
                                   :per_page => PRODUCTS_PER_PAGE)
  end

public

  def mainpage
    authorize! :index, Product
    @products = Product.accessible_by(current_ability)

    @featured_products = @products.where(:featured => true)

    # no need to load the product list for mobile site, because it won't
    # be shown on the mobile main page
    fetch_data_for_index(params) unless mobile_device?
  end

  # GET /products
  # GET /products.xml
  def index
    fetch_data_for_index(params)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
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

    comments = @product.comments.accessible_by(current_ability)
    @comments = comments.where(:admin_comment => false)
    @admin_comments = comments.where(:admin_comment => true)

    @new_admin_comment = @product.comments.build(:commenter => current_user)
    @new_admin_comment.admin_comment = true
    @new_admin_comment = nil unless can? :new, @new_admin_comment

    # which product approval state related buttons are applicable
    # in the current state:
    @approval_buttons =
      case @product.approval_state
        when 'pending'   then Set[:approve, :block]
        when 'published' then Set[:block]
        when 'blocked'   then Set[:request_approval, :approve]
      end
    @approval_buttons.keep_if { |action| can? action, @product }

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
          UserMailer.new_product(@product).deliver rescue nil

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
    # prevent deletion of new photo if delete photo checked when new photo uploaded
    params[:product].delete(:delete_photo) if params[:product][:photo].present?

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
    @product.change_approval 'published'
    UserMailer.product_approved(@product, current_user).deliver rescue nil
    redirect_to :back
  end

  def block
    @product.change_approval 'blocked'
    UserMailer.product_blocked(@product, current_user).deliver rescue nil
    redirect_to :back
  end

  def request_approval
    @product.change_approval 'pending'
    UserMailer.product_approval_request(@product).deliver rescue nil
    redirect_to :back
  end

  def promote
    @product.featured = true
    @product.save!
    redirect_to :back
  end

  def demote
    @product.featured = false
    @product.save!
    redirect_to :back
  end

  def autocomplete_tags
    pattern = params[:term]
    if pattern
      pattern.gsub!(/[%_]/, '\\\\\1')
      render :json =>
        Product.tag_counts.
          where('lower(tags.name) LIKE lower(?)', "#{pattern}%").
          order('lower(tags.name) ASC').
          limit(TAG_AUTOCOMPLETE_LIMIT).
          map(&:name)
    else
      render :json => []
    end
  end

private

  def add_popularity
    # increase popularity without triggering validations or callbacks
    Product.where(:id => params[:id]).update_all('popularity = popularity + 1')
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
