class AddPlatformDonateToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :platform, :string
		add_column :products, :donate, :string
  end

  def self.down
		remove_column :products, :platform
		remove_column :products, :donate
  end
end
