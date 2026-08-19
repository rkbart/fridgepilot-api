class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :description
      t.jsonb :ingredients
      t.text :instructions
      t.string :cuisine
      t.integer :prep_time
      t.integer :cook_time
      t.integer :servings
      t.string :source
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
