class Platform < ActiveRecord::Base
  validates :name, :presence => true,
                   :uniqueness => true,
                   :length => { :minimum => 3 }
  has_and_belongs_to_many :products, :uniq => true
  before_destroy :cancel_unless_no_products

  private

  def cancel_unless_no_products
    # prevent deletion of platforms that have products
    raise ActiveRecord::DeleteRestrictionError, Product  if products.exists?
    true
  end
end
