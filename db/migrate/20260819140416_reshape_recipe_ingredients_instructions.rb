class ReshapeRecipeIngredientsInstructions < ActiveRecord::Migration[8.1]
  def up
    Recipe.find_each do |recipe|
      steps = recipe.instructions.to_s.split("\n").map(&:strip).reject(&:empty?)
      ingredients = Array(recipe.ingredients).map { |i| i.is_a?(String) ? { "name" => i } : i }
      recipe.update_columns(instructions: steps.to_json, ingredients: ingredients)
    end

    execute "ALTER TABLE recipes ALTER COLUMN instructions TYPE jsonb USING instructions::jsonb, ALTER COLUMN instructions SET DEFAULT '[]'::jsonb"
  end

  def down
    execute "ALTER TABLE recipes ALTER COLUMN instructions TYPE text USING instructions::text"

    Recipe.find_each do |recipe|
      text = Array(recipe.instructions).join("\n")
      recipe.update_columns(instructions: text)
    end
  end
end
