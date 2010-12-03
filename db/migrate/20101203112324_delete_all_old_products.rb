class DeleteAllOldProducts < ActiveRecord::Migration
  def self.up
    Product.delete_all
  end

  def self.down
  end
end
