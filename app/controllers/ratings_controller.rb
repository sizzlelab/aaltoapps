class RatingsController < ApplicationController
  # POST /ratings
  # POST /ratings.xml
  def create
    success = false

    if logged_in?
      # create a rating if one doesn't exist for the product/user pair
      # otherwise update the existing rating
      Rating.transaction do
        @rating = Rating.find_or_initialize_by_product_id_and_user_id(
          :product_id => params[:rating][:product_id] || params[:product_id],
          :user_id => current_user.id )
        if params[:rating][:rating].empty?
          # if the new rating value is empty, destroy the rating if it exists
          @rating.destroy unless @rating.new_record?
          success = true
        else
          @rating.rating = params[:rating][:rating]
          success = @rating.save
          raise ActiveRecord::Rollback unless success
        end
      end
    else
      # create empty Rating for error message
      @rating = Rating.new
      @rating.errors.add :rating, 'can not be given when not logged in'
    end

    respond_to do |format|
      if success
        format.html { redirect_to(:back, :notice => 'Rating was successfully created/updated.') }
        format.xml  { render :xml => @rating, :status => :created, :location => @rating }
      else
        format.html {
          # put error messages to :alert flash message
          errmsg = @rating.errors.full_messages.join(', ')
          errmsg = " (#{errmsg})" unless errmsg.empty?
          redirect_to(:back, :alert => 'Rating was not created/updated.' + errmsg)
        }
        format.xml  { render :xml => @rating.errors, :status => :unprocessable_entity }
      end
    end
  end
end
