class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  has_and_belongs_to_many :platforms, :uniq => true
  validates :name, :description, :url, :platforms, :presence => true
  validates :name, :length => { :minimum => 3 }
  validates :url, :length => { :minimum => 12 } # http://ab.cd
  validates :approval_state, :inclusion => { :in => %w( submitted pending published blocked ) }
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_attached_file :photo, :styles => { :thumb=> "75x75#",:small => "150x150>" },
    :url  => "/:class/:attachment/:id/:style_:basename.:extension",
    :default_url => "/images/:style_missing.png",
    :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension"
  #	validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
  attr_accessor :delete_photo
  before_update :delete_photo_handler
  has_many :downloads, :dependent => :destroy
  accepts_nested_attributes_for :downloads, :allow_destroy => true,
    :reject_if => proc { |attrs| !attrs['file'] }
  validates :terms, :acceptance => true
  attr_accessor :terms

  attr_protected :publisher_id, :approval_state, :approval_date, :featured, :popularity

  def is_approved?
    self.approval_state == 'published'
  end

  def change_approval state
    self.approval_state = state.to_s
    self.approval_date = DateTime.now
    self.save!	
  end

  def delete_photo_handler
    self.photo = nil if self.delete_photo == '1'
  end

end
