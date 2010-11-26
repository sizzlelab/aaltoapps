class Rating < ActiveRecord::Base
  @@min = 1
  @@max = 5
  @@step = 0.5

  belongs_to :user
  belongs_to :product
  validates :rating, :user_id, :product_id, :presence => true
  validates :rating, :inclusion => {:in => (@@min..@@max).step(@@step).to_a}

  def before_save
    self.product.avg_rating = self.product.ratings.average(:rating)  
    self.product.save!
  end

  def to_f
    self.rating
  end

  def self.allowed_values
    return (@@min..@@max).step(@@step).to_a
  end
end
