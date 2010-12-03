class CreateProductsPlatforms < ActiveRecord::Migration
  def self.up
    create_table "platforms_products", :id => false do |t|
      t.column :product_id, :integer, :null => false
      t.column :platform_id, :integer, :null => false
    end
  end

  def self.down
    arop_table "platforms_products"
  end
end
