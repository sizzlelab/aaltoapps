class ChangeIsApprovedToString < ActiveRecord::Migration
  def self.up
    add_column :products, :approval_state, :string, :null => false, :default => 'submitted'
    Product.update_all({ :approval_state => 'submitted' }, { :is_approved => nil })
    Product.update_all({ :approval_state => 'published' }, { :is_approved => true })
    Product.update_all({ :approval_state => 'blocked'   }, { :is_approved => false })
    remove_column :products, :is_approved
  end

  def self.down
    remove_column :products, :approval_state
		add_column :products, :is_approved, :boolean
  end
end
