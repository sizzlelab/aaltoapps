class ModifyUserForAsi < ActiveRecord::Migration
  def self.up
    remove_column :users, :username
    remove_column :users, :firstname
    remove_column :users, :lastname
    remove_column :users, :email
    add_column :users, :asi_id, :string
  end

  def self.down
  end
end
