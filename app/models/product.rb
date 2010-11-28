class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  belongs_to :platform
  validates :name, :description, :url, :platform, :donate,:presence => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy

def self.find_apps_by(platform)
   Platform.find(platform).products
end
def self.sort_apps_by(platform,criteria)
   #order("#{criteria}").find_all_by_platform(platform)
   Platform.find(platform).products.order("#{criteria}")
end
end
