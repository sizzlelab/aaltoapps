class Rating < ActiveRecord::Base
  Max = 5
  Increment = 0.5

  belongs_to :user
  belongs_to :product
  validates :rating, :user_id, :product_id, :presence => true
  
  def to_f
    self.rating
  end
end
