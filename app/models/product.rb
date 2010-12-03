class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  belongs_to :platform
  validates :name, :description, :url, :platform, :category, :donate, :publisher, :presence => true
  validates :name, :length => { :minimum => 3 }
  validates :url, :length => { :minimum => 12 } # http://ab.cd 
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
end
