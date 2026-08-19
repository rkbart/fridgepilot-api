class Api::V1::RecipesController < Api::V1::BaseController
  before_action :set_recipe, only: [:show, :update, :destroy]

  def index
    recipes = current_user.recipes
    render json: recipes.map { |r| RecipeSerializer.new(r).serializable_hash }
  end

  def show
    render json: RecipeSerializer.new(@recipe).serializable_hash
  end

  def create
    recipe = current_user.recipes.build(recipe_params)
    if recipe.save
      render json: RecipeSerializer.new(recipe).serializable_hash, status: :created
    else
      render json: { error: { code: 422, message: recipe.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      render json: RecipeSerializer.new(@recipe).serializable_hash
    else
      render json: { error: { code: 422, message: @recipe.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    head :no_content
  end

  private

  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, ingredients: [:name, :quantity, :unit], instructions: [])
  end
end
