class User < ActiveRecord::Base

  has_many :ratings, :dependent => :destroy

end
