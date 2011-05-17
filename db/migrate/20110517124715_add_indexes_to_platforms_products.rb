class AddIndexesToPlatformsProducts < ActiveRecord::Migration
  def self.up
    add_index :platforms_products, :product_id
    add_index :platforms_products, :platform_id
  end

  def self.down
    remove_index :platforms_products, :product_id
    remove_index :platforms_products, :platform_id
  end
end
