class CreateProductsPlatforms < ActiveRecord::Migration
  def self.up
    create_table "products_platforms" do |t|
      t.column :product_id, :integer, :null => false
      t.column :platform_id, :integer, :null => false
    end
  end

  def self.down
    drop_table "products_platforms"
  end
end
