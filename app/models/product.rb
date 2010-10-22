class Product < ActiveRecord::Base

  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy

end
