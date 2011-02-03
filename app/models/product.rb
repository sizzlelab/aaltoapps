class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  has_and_belongs_to_many :platforms, :uniq => true
  validates :name, :description, :url, :category, :presence => true
  validates :name, :length => { :minimum => 3 }
  validates :url, :length => { :minimum => 12 } # http://ab.cd 
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
	has_attached_file :photo, :styles => { :thumb=> "75x75#",:small => "150x150>" },
                  :url  => "/:class/:attachment/:id/:style_:basename.:extension",
                  :default_url => "/:class/:attachment/missing_:style.png",
                  :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension"
#	validates_attachment_presence :photo
	validates_attachment_size :photo, :less_than => 5.megabytes
	validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']

end
