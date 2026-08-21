class RecipeSerializer
  def initialize(recipe)
    @recipe = recipe
  end

  def serializable_hash
    {
      id: @recipe.id,
      name: @recipe.name,
      image_url: @recipe.image.attached? ? Rails.application.routes.url_helpers.url_for(@recipe.image) : @recipe.image_url,
      ingredients: @recipe.ingredients,
      instructions: @recipe.instructions,
      created_at: @recipe.created_at,
      updated_at: @recipe.updated_at
    }
  end
end
