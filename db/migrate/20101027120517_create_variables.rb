class CreateVariables < ActiveRecord::Migration
  def self.up
    create_table :variables do |t|
      t.string :key, :null => false
      t.string :value, :null => false
    end
  end

  def self.down
    drop_table :variables
  end
end
