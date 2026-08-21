class RecipeSerializer
  def initialize(recipe)
    @recipe = recipe
  end

  def serializable_hash
    {
      id: @recipe.id,
      name: @recipe.name,
      image_url: image_url,
      ingredients: @recipe.ingredients,
      instructions: @recipe.instructions,
      created_at: @recipe.created_at,
      updated_at: @recipe.updated_at
    }
  end

  private

  def image_url
    return @recipe.image_url if @recipe.image_url.present?
    return nil unless @recipe.image.attached?

    rails_blob_url(@recipe.image)
  end

  def rails_blob_url(blob)
    Rails.application.routes.url_helpers.url_for(
      controller: "/active_storage/blobs/redirect",
      action: :show,
      signed_id: blob.signed_id,
      filename: blob.filename
    )
  rescue => e
    Rails.logger.warn("Failed to generate blob URL: #{e.message}")
    nil
  end
end
