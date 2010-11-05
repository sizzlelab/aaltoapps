class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
	has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
	validates :asi_id, :presence => true
  has_many :comments
end
