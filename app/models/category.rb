class Category < ActiveRecord::Base
  validates_presence_of :name
  has_many :products, :dependent => :destroy
end
