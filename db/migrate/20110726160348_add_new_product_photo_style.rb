class AddNewProductPhotoStyle < ActiveRecord::Migration
  def self.up
    # create new thumbnails of the style :mobile_thumb for all products
    Product.find_each do |product|
      product.photo.reprocess! :mobile_thumb
    end
  end

  def self.down
    # Paperclip doesn't seem to have an API for deleting files when a style
    # is removed, but the actual files seem to be the only thing that needs
    # to be deleted, so we'll just do that.
    Dir[Rails.root + 'public/products/photos/*/mobile_thumb_*'].each do |f|
      File.delete f
    end
  end
end
