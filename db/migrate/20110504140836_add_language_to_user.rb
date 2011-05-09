class AddLanguageToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :language, :string, :null => true
    User.update_all :language => APP_CONFIG.fallback_locale || 'en'
    change_column :users, :language, :string, :null => false
  end

  def self.down
    remove_column :users, :language
  end
end
