class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  has_and_belongs_to_many :platforms
  validates :name, :description, :url, :platform, :category, :donate,:presence => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
end
