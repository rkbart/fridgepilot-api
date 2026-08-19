class CreateGroceryLists < ActiveRecord::Migration[8.1]
  def change
    create_table :grocery_lists do |t|
      t.string :name
      t.string :source
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
