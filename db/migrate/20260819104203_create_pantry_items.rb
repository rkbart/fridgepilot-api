class CreatePantryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :pantry_items do |t|
      t.string :name
      t.decimal :quantity
      t.string :unit
      t.string :category
      t.date :expires_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
