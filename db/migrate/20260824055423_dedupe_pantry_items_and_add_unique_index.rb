class DedupePantryItemsAndAddUniqueIndex < ActiveRecord::Migration[8.1]
  def up
    execute <<~'SQL'
      DELETE FROM pantry_items p
      USING pantry_items keeper
      WHERE p.user_id = keeper.user_id
        AND LOWER(TRIM(REGEXP_REPLACE(p.name, '\s+', ' ', 'g')))
          = LOWER(TRIM(REGEXP_REPLACE(keeper.name, '\s+', ' ', 'g')))
        AND p.id > keeper.id
    SQL

    add_index :pantry_items,
      "user_id, LOWER(TRIM(REGEXP_REPLACE(name, '\\s+', ' ', 'g')))",
      name: "index_pantry_items_on_user_normalized_name",
      unique: true
  end

  def down
    remove_index :pantry_items, name: "index_pantry_items_on_user_normalized_name"
  end
end
