class AddCloudinaryPublicIdToOutfits < ActiveRecord::Migration[8.1]
  def change
    add_column :outfits, :cloudinary_public_id, :string
  end
end
