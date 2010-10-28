class AddIndexesAndNotNullsToRating < ActiveRecord::Migration
  def self.up
    change_table :ratings do |t|
      t.index :product_id
      t.index [:user_id, :product_id], :unique => true

      t.change :user_id,    :integer, :null => false
      t.change :product_id, :integer, :null => false
      t.change :rating,     :float,   :null => false
    end
  end

  def self.down
    change_table :ratings do |t|
      t.remove_index :column => :product_id
      t.remove_index :column => [:user_id, :product_id]

      t.change :user_id,    :integer, :null => true
      t.change :product_id, :integer, :null => true
      t.change :rating,     :float,   :null => true
    end
  end
end
