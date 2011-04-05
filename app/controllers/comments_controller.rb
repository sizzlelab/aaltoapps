class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    @comment.product = Product.find(params[:product_id])
    @comment.commenter = current_user

    if params[:comment][:admin_comment]
      @comment.admin_comment = params[:comment][:admin_comment]
      # check the authorization using @comment with values set
      # so that only authorized users can create admin comments
      authorize! :create, @comment
    end

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@comment.product, :notice => _('New comment created.')) }
        format.xml  { head :ok }
      else
        format.html {
          # put error messages to :alert flash message
          errmsg = @comment.errors.full_messages.join(', ')
          errmsg = " (#{errmsg})" unless errmsg.empty?
          redirect_to(:back, :alert => _('Comment was not created.') + errmsg)
        }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(@comment.product, :notice => _('Your comment was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html {
          # put error messages to :alert flash message
          errmsg = @comment.errors.full_messages.join(', ')
          errmsg = " (#{errmsg})" unless errmsg.empty?
          redirect_to(:back, :alert => _('Your comment was not updated.') + errmsg)
        }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(@comment.product, :notice => _('Comment deleted.')) }
      format.xml  { head :ok }
    end
  end

end
