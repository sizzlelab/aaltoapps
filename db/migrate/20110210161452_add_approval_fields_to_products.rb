class AddApprovalFieldsToProducts < ActiveRecord::Migration
  def self.up
		add_column :products, :is_approved, :boolean
		add_column :products, :approval_date, :datetime
  end

  def self.down
		remove_columns :products, :is_approved, :approval_date
  end
end
