require File.join(File.dirname(__FILE__), '20101114121109_add_rating_to_products.rb')

class RemoveRatingFieldFromProducts < ActiveRecord::Migration
  def self.up
    AddRatingToProducts.down
  end

  def self.down
    AddRatingToProducts.up
  end
end
