class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
	has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
	validates_presence_of :username, :firstname, :lastname, :email
  has_many :comments
end
