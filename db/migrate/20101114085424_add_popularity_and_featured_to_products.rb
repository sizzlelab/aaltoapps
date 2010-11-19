class AddPopularityAndFeaturedToProducts < ActiveRecord::Migration
  def self.up
    add_column :products,:popularity,:integer,:default=>0
    add_column :products,:featured,:boolean,:default=>false
  end

  def self.down
    remove_column :products,:popularity
    remove_column :products,:featured
  end
end
