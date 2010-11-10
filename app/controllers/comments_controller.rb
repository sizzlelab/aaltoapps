class CommentsController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    @comment = @product.comments.build :body => params[:comment][:body], :commenter => current_user
    @comment.save
    redirect_to product_path(@product)
  end
end

