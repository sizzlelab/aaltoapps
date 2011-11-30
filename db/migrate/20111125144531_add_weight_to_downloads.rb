class AddWeightToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :weight, :integer, :null => false, :default => 0
  end
end
