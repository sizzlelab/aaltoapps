class Product < ActiveRecord::Base
	belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
	validates_presence_of :name, :description, :url
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
end