class RemoveDonationFromProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :donate
  end

  def self.down
    add_column :products, :platform, :string
  end
end
