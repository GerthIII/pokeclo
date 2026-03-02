class CreateOutfits < ActiveRecord::Migration[8.1]
  def change
    create_table :outfits do |t|
      t.string :name
      t.text :description
      t.integer :status, default: "draft"

      t.timestamps
    end
  end
end
