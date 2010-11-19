class Product < ActiveRecord::Base
	belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
	belongs_to :category
	belongs_to :platform
	validates :name, :description, :url, :platform, :donate,:presence => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  #default_scope order("updated_at DESC")
  def average_rating
    ratings.average(:rating)
  end
  
  def self.find_apps_by(platform)
    find_all_by_platform(platform)
  end
  
  def self.sort_apps_by(platform,criteria)
   order("#{criteria}").find_all_by_platform(platform)
  end
end
