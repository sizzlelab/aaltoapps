class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.references :product
      t.string :title, :null => false

      t.string   :file_file_name
      t.string   :file_content_type
      t.integer  :file_file_size
      t.datetime :file_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :downloads
  end
end
