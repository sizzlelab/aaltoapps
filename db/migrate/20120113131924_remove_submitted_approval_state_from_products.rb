class RemoveSubmittedApprovalStateFromProducts < ActiveRecord::Migration
  def up
    # Try to remove the default value of products.approval_state by setting it
    # to nil. It's not certain that this works in all database adapters, so
    # we'll check that the default value is removed. If it's not removed, it
    # may break handling of the configuration setting
    # require_approval_for_new_products.
    change_column_default :products, :approval_state, nil
    if columns(:products).find {|col| col.name == 'approval_state' }.has_default?
      raise "Couldn't remove default value from products.approval_state"
    end

    Product.where(:approval_state => 'submitted').update_all(:approval_state => 'pending')
  end

  def down
    change_column_default :products, :approval_state, 'submitted'
  end
end
