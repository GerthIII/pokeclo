class AddUserIdToOutfits < ActiveRecord::Migration[8.1]
  def change
    add_reference :outfits, :user, null: false, foreign_key: true
  end
end
