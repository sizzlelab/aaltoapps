class AddPopularityAndFeaturedToExistingProducts < ActiveRecord::Migration
  def self.up
    Product.update_all({ :popularity => 0 }, "popularity IS NULL")
    Product.update_all({ :featured => false }, "featured IS NULL")
    change_column :products, :popularity, :integer, :default => 0,     :null => false
    change_column :products, :featured,   :boolean, :default => false, :null => false
  end

  def self.down
    change_column :products, :popularity, :integer, :default => 0,     :null => true
    change_column :products, :featured,   :boolean, :default => false, :null => true
  end
end
