class AddAdminCommentFieldToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :admin_comment, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :comments, :admin_comment
  end
end
