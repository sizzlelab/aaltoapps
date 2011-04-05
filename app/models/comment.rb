class Comment < ActiveRecord::Base
  belongs_to :product
  belongs_to :commenter, :class_name => "User", :foreign_key => "commenter_id"

  validates :commenter, :product, :presence => true
  validates :body, :length => { :minimum => 3 }

  attr_protected :admin_comment

  def commenter_rating
    return product.ratings.find_by_user_id commenter
  end

  def admin_comment?
    admin_comment
  end
end
