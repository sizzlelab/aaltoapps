class Product < ActiveRecord::Base
	belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
	validates :name, :description, :url, :presence => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  def average_rating
    ratings.average(:rating)
  end
end
