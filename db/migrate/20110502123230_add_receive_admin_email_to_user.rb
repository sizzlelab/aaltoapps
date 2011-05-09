class AddReceiveAdminEmailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_admin_email, :boolean, :null => false, :default => false

    # add index containing only admin email recipients, if the database supports it
    case adapter_name
      when 'PostgreSQL'
        execute <<-SQL
          CREATE INDEX index_users_on_receive_admin_email
            ON users(receive_admin_email)
            WHERE receive_admin_email
        SQL
    end
  end

  def self.down
    remove_column :users, :receive_admin_email
    remove_index :users, :receive_admin_email  if index_exists? :users, :receive_admin_email
  end
end
