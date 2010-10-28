class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  validates_presence_of :rating, :user_id, :product_id
end
