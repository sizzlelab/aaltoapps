class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  has_many :comments
end
