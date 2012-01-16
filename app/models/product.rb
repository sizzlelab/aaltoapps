class Product < ActiveRecord::Base
  belongs_to :publisher, :class_name => "User", :foreign_key => "publisher_id"
  belongs_to :category
  has_and_belongs_to_many :platforms, :uniq => true
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :downloads, :dependent => :destroy
  has_attached_file :photo, :styles => { :mobile_thumb => "40x40#", :thumb => "75x75#", :small => "150x150>" },
    :url  => "/:class/:attachment/:id/:style_:basename.:extension",
    :default_url => "/images/:style_missing.png",
    :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension"
  acts_as_taggable_on :tags

  validates :name, :description, :url, :platforms, :presence => true
  validates :name, :length => { :minimum => 3 }
  validates :url, :length => { :minimum => 12 } # http://ab.cd
  validates :approval_state, :inclusion => { :in => %w( pending published blocked ) }
  validates :terms, :acceptance => true

  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
  #	validates_attachment_presence :photo

  attr_accessor :terms
  attr_accessor :delete_photo
  before_update :delete_photo_handler

  accepts_nested_attributes_for :downloads, :allow_destroy => true,
    # if no file given in new download field, ignore the download:
    :reject_if => proc { |attrs| !attrs['id'] && !attrs['file'] }
  before_save :recalculate_download_weights

  include MarkdownHelper
  markdown_fields :description

  attr_protected :publisher_id, :approval_state, :approval_date, :featured, :popularity

  after_initialize do |product|
    # set default value for approval_state according to configuration
    self.approval_state ||=
      if APP_CONFIG.require_approval_for_new_products == false  # must be false, not nil
        'published'
      else  # true, nil (not set) or anything except false
        'pending'
      end
  end

  def is_approved?
    self.approval_state == 'published'
  end

  def change_approval state
    self.approval_state = state.to_s
    self.approval_date = DateTime.now
    self.save!	
  end

private

  def delete_photo_handler
    self.photo = nil if self.delete_photo == '1'
  end

  def recalculate_download_weights
    i = 1
    downloads.sort_by(&:weight_as_float).each do |d|
      d.weight = i
      i += 1
    end
  end

end
