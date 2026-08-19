class CreateGroceryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :grocery_items do |t|
      t.string :name
      t.decimal :quantity
      t.string :unit
      t.string :category
      t.string :status
      t.string :source
      t.references :recipe, null: false, foreign_key: true
      t.references :grocery_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
