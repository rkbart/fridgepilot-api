class AddStatusToGroceryLists < ActiveRecord::Migration[8.1]
  def change
    add_column :grocery_lists, :status, :string, null: false, default: "active"
    add_index :grocery_lists, [ :user_id, :status ]
  end
end
