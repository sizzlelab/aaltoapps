class AddRatingToProducts < ActiveRecord::Migration
  def self.up
    add_column :products,:rating,:float
  end

  def self.down
    remove_column :products,:rating
  end
end
