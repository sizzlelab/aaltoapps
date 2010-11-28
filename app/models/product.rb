class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  belongs_to :platform
  validates :name, :description, :url, :platform, :donate,:presence => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
def average_rating
    ratings.average(:rating)
  end


end
