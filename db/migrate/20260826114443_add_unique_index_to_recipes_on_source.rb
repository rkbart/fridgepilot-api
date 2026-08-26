class AddUniqueIndexToRecipesOnSource < ActiveRecord::Migration[8.1]
  def up
    # Remove duplicate recipes, keeping the oldest one
    execute <<-SQL
      DELETE FROM recipes
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM recipes
        WHERE source IS NOT NULL
        GROUP BY user_id, source
      )
      AND source IS NOT NULL
    SQL

    add_index :recipes, [:user_id, :source], unique: true, name: "index_recipes_on_user_id_and_source_unique", where: "source IS NOT NULL"
  end

  def down
    remove_index :recipes, name: "index_recipes_on_user_id_and_source_unique"
  end
end
