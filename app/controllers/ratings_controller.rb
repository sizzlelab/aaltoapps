class RatingsController < ApplicationController
  # POST /ratings
  # POST /ratings.xml
  def create
    status = :unprocessable_entity
    # create empty Rating for error message
    @rating = Rating.new

    if logged_in?
      begin
        product = Product.find(params[:rating][:product_id] || params[:product_id])
        if product.publisher != current_user
          # create a rating if one doesn't exist for the product/user pair
          # otherwise update the existing rating
          Rating.transaction do
            @rating = Rating.find_or_initialize_by_product_id_and_user_id(
              :product_id => product.id,
              :user_id => current_user.id )
            if params[:rating][:rating].empty?
              # if the new rating value is empty, destroy the rating if it exists
              @rating.destroy unless @rating.new_record?
              status = :ok
            else
              @rating.rating = params[:rating][:rating]
              status = @rating.save ? :ok : :unprocessable_entity
              raise ActiveRecord::Rollback unless status == :ok
            end
          end
        else
          # publisher tried to rate his/her own product
          @rating.errors.add :rating, _('can not be given by the publisher of the product')
          status = :forbidden
        end
      rescue RecordNotFound
        @rating.errors.add :rating, _('can not be given for nonexistent product')
        status = :unprocessable_entity
      end
    else
      @rating.errors.add :rating, _('can not be given when not logged in')
      status = :forbidden
    end

    respond_to do |format|
      if status == :ok
        format.html { redirect_to(:back, :notice => _('Rating was successfully created/updated.')) }
        format.xml  { render :xml => @rating, :status => :created, :location => @rating }
      else
        format.html {
          # put error messages to :alert flash message
          errmsg = @rating.errors.full_messages.join(', ')
          errmsg = " (#{errmsg})" unless errmsg.empty?
          redirect_to(:back, :alert => _('Rating was not created/updated.') + errmsg)
        }
        format.xml  { render :xml => @rating.errors, :status => status }
      end
    end
  end
end
