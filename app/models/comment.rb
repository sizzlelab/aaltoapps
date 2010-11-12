class Comment < ActiveRecord::Base
  belongs_to :product
  belongs_to :commenter, :class_name => "User", :foreign_key => "commenter_id"

  def commenter_rating
    return product.ratings.find_by_user_id commenter
  end
end

