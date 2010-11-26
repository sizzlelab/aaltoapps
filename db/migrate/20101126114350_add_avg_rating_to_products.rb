class AddAvgRatingToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :avg_rating, :float
  end

  def self.down
    remove_column :products, :avg_rating
  end
end
