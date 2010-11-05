class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
	has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
	validates :username, :firstname, :lastname, :email, :presence => true
  has_many :comments
end
