class Api::V1::RecipesController < Api::V1::BaseController
  before_action :set_recipe, only: [ :show, :update, :destroy ]

  def index
    scope = current_user.recipes
    scope = apply_search(scope) if params[:q].present?
    page = [ params[:page].to_i, 1 ].max
    per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
    recipes = scope.order(:name).offset((page - 1) * per_page).limit(per_page)
    render json: {
      data: recipes.map { |r| RecipeSerializer.new(r).serializable_hash },
      meta: { total: scope.count, page: page, per_page: per_page }
    }
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

  def apply_search(scope)
    q = params[:q].strip
    escaped = q.gsub(/["\\^$.|?*+()\[\]{}]/) do |c|
      case c
      when '"' then '\\"'
      when "\\" then "\\\\\\\\"
      else "\\\\\\\\#{c}"
      end
    end
    path = %Q{$[*].name ? (@ like_regex ".*#{escaped}.*" flag "i")}
    scope.where("name ILIKE ? OR jsonb_path_exists(ingredients, ?)", "%#{q}%", path)
  end

  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, :image_url, ingredients: [ :name, :quantity, :unit ], instructions: [])
  end
end
