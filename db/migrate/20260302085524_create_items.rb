class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.jsonb :characteristics, default: {}
      t.string :category
      t.text :description
      t.string :name
      t.integer :status, default: "pending"
      t.string :season
      t.string :slot
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
