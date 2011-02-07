class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    @comment.product = Product.find(params[:product_id])
    @comment.commenter = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@comment.product, :notice => 'New comment created.') }
        format.xml  { head :ok }
      else
        format.html {
          # put error messages to :alert flash message
          errmsg = @comment.errors.full_messages.join(', ')
          errmsg = " (#{errmsg})" unless errmsg.empty?
          redirect_to(:back, :alert => 'Comment was not created.' + errmsg)
        }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(@comment.product, :notice => 'Your comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html {
          # put error messages to :alert flash message
          errmsg = @comment.errors.full_messages.join(', ')
          errmsg = " (#{errmsg})" unless errmsg.empty?
          redirect_to(:back, :alert => 'Your comment was not updated.' + errmsg)
        }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(@comment.product, :notice => 'Comment deleted.') }
      format.xml  { head :ok }
    end
  end

end
