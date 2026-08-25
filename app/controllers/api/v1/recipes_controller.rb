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
    recipe.image.attach(params[:recipe][:image]) if params[:recipe][:image].present?
    if recipe.save
      render json: RecipeSerializer.new(recipe).serializable_hash, status: :created
    else
      render json: { error: { code: 422, message: recipe.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def update
    if params[:recipe][:image].present?
      @recipe.image.attach(params[:recipe][:image])
    elsif params[:recipe].key?(:image_url) && params[:recipe][:image_url].blank?
      @recipe.image.purge_later if @recipe.image.attached?
    end
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

  def import
    meal_id = params[:meal_id].to_s.strip
    if meal_id.blank?
      render json: { error: { code: 422, message: "meal_id is required" } }, status: :unprocessable_entity
      return
    end

    client = TheMealDbClient.new
    meal = client.lookup_recipe(meal_id)
    if meal.nil?
      render json: { error: { code: 404, message: "Recipe not found on TheMealDB" } }, status: :not_found
      return
    end

    recipe = current_user.recipes.build(
      name: meal[:name],
      image_url: meal[:image_url],
      source: "themealdb:#{meal_id}",
      instructions: split_instructions(meal[:instructions]),
      ingredients: meal[:ingredients].map { |ing| transform_ingredient(ing) }
    )

    if recipe.save
      render json: RecipeSerializer.new(recipe).serializable_hash, status: :created
    else
      render json: { error: { code: 422, message: recipe.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  rescue TheMealDbClient::ApiError => e
    render json: { error: { code: 502, message: e.message } }, status: :bad_gateway
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

  def split_instructions(text)
    return [] if text.blank?
    text.split(/\r?\n/).map(&:strip).reject(&:blank?)
  end

  def transform_ingredient(ing)
    quantity, unit = parse_measure(ing[:measure])
    { name: ing[:name], quantity: quantity, unit: unit }
  end

  def parse_measure(measure)
    return [ nil, nil ] if measure.blank?
    trimmed = measure.strip
    # Try to extract leading numeric quantity (supports decimals and fractions like 1/2)
    qty_match = trimmed.match(/^([\d.\/]+)/)
    unless qty_match
      return [ nil, trimmed ]
    end

    qty_str = qty_match[1]
    rest = trimmed[qty_match[0].length..].strip

    quantity = if qty_str.include?("/")
      parts = qty_str.split("/")
      parts.length == 2 ? parts[0].to_f / parts[1].to_f : qty_str.to_f
    else
      qty_str.to_f
    end

    quantity = nil if quantity.zero?
    unit = rest.empty? ? nil : rest

    [ quantity, unit ]
  end
end
