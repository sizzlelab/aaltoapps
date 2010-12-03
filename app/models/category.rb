class Category < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :name, :length => { :minimum => 3 }
  has_many :products, :dependent => :destroy
end
