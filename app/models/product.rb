class Product < ActiveRecord::Base

  has_many :ratings, :dependent => :destroy

end
