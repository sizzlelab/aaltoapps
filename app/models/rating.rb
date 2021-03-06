class Rating < ActiveRecord::Base
  MIN = 1
  MAX = 5
  STEP = 1

  belongs_to :user
  belongs_to :product
  validates :rating, :user, :product, :presence => true
  validates :rating, :inclusion => {:in => (MIN..MAX).step(STEP).to_a }
  after_save :add_avg_rating_to_product
  after_destroy :add_avg_rating_to_product

  def add_avg_rating_to_product
    self.product.avg_rating = self.product.ratings.average(:rating)  
    self.product.save!
  end

  def to_f
    self.rating 
  end

  def self.allowed_values
    return (MIN..MAX).step(STEP).map &:to_f
  end

end
