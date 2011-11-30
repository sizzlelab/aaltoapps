class Download < ActiveRecord::Base
  belongs_to :product

  has_attached_file :file,
    :url  => "/products/:class/:id/:basename.:extension",
    :default_url => '#',
    :path => ":rails_root/public/products/:class/:id/:basename.:extension"
  validates_attachment_presence :file

  validates :title, :presence => true

  default_scope :order => 'weight'

  # Custom writer for weight. Saves the value temporarily as float.
  # (needed because weight_before_type_cast doesn't always work)
  def weight=(value)
    @weight_as_float = value.to_f
    super(value)
  end

  def weight_as_float
    @weight_as_float || weight.to_f
  end
end
