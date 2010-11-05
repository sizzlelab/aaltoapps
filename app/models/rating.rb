class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  validates :rating, :user_id, :product_id, :presence => true
  
  def to_f
    self.rating
  end
end
