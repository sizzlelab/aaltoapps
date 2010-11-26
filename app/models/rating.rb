class Rating < ActiveRecord::Base
  MIN = 1
  MAX = 5
  STEP = 0.5

  belongs_to :user
  belongs_to :product
  validates :rating, :user_id, :product_id, :presence => true
  validates :rating, :inclusion => {:in => (MIN..MAX).step(STEP).to_a }

  def before_save
    self.product.avg_rating = self.product.ratings.average(:rating)  
    self.product.save!
  end

  def to_f
    self.rating
  end

  def self.allowed_values
    return (MIN..MAX).step(STEP).to_a
  end
end
