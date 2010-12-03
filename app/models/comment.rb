class Comment < ActiveRecord::Base
  belongs_to :product
  belongs_to :commenter, :class_name => "User", :foreign_key => "commenter_id"

  validates :commenter, :product, :presence => true
  validates :body, :length => { :minimum => 3 }

  def commenter_rating
    return product.ratings.find_by_user_id commenter
  end
end

