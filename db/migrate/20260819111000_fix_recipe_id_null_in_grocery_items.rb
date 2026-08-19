class FixRecipeIdNullInGroceryItems < ActiveRecord::Migration[8.1]
  def change
    change_column_null :grocery_items, :recipe_id, true
  end
end
