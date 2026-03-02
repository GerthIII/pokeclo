class CreateOutfitItems < ActiveRecord::Migration[8.1]
  def change
    create_table :outfit_items do |t|
      t.references :item, null: false, foreign_key: true
      t.references :outfit, null: false, foreign_key: true
      t.string :slot

      t.timestamps
    end
  end
end
