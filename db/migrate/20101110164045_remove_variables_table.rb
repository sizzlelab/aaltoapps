class RemoveVariablesTable < ActiveRecord::Migration
  def self.up
    drop_table :variables
  end

  def self.down
  end
end
