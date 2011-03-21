class Download < ActiveRecord::Base
  belongs_to :product
  has_attached_file :file,
    :url  => "/products/:class/:id/:basename.:extension",
    :default_url => '#',
    :path => ":rails_root/public/products/:class/:id/:basename.:extension"
  validates_attachment_presence :file

  validates :title, :presence => true
end
