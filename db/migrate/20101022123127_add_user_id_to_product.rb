class AddUserIdToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :publisher_id, :integer
  end

  def self.down
    remove_column :products, :publisher_id, :integer
  end
end
