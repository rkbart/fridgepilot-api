class AddUniqueIndexToGroceryLists < ActiveRecord::Migration[8.1]
  def change
    add_index :grocery_lists, [:user_id, :name], unique: true, name: "index_grocery_lists_on_user_id_and_name_unique"
  end
end
