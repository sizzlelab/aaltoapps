class RemovePlatformIdFromProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :platform_id
  end

  def self.down
    add_column :products, :platform_id
  end
end
