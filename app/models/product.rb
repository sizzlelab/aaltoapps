class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  has_and_belongs_to_many :platforms, :uniq => true
  validates :name, :description, :url, :category, :donate,:presence => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  scope :has_platform?, lambda {|platform_id| joins(:platforms).count("platform.id IN ( ? )", platform_id) > 0}
end
