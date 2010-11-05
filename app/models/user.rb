class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
	has_many :published, :class_name => "Product", :foreign_key => "publisher_id"
	validates :asi_key, :presence => true
  has_many :comments
  
  def self.create(params)
    response = AsiSession.new.register(:username => params[:username], 
                                      :password => params[:password], 
                                      :email => params[:email], 
                                      :is_association => false, 
                                      :consent => params[:consent])
  end
end
