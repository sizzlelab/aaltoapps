class FixPlatformDatatypeInProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :platform
    add_column :products, :platform_id, :integer
  end

  def self.down
    remove_column :products, :platform_id
    add_column :products, :platform, :string
  end
end
