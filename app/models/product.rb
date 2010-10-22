class Product < ActiveRecord::Base
	belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
	validates_presence_of :name, :description, :url
end
