class Api::V1::DiscoverController < Api::V1::BaseController
  MAX_RESULTS = 30

  def index
    ingredients = Array(params[:ingredients]).reject(&:blank?).map(&:strip)

    if ingredients.empty?
      render json: { recipes: [], meta: { total_searched: 0, returned: 0, query_ingredients: [] } }
      return
    end

    client = TheMealDbClient.new
    recipe_ids = search_recipes(client, ingredients)

    full_recipes = fetch_full_recipes(client, recipe_ids, ingredients)

    matcher = RecipeMatcher.new(ingredients)
    ranked = full_recipes
      .map { |recipe| matcher.match(recipe) }
      .sort_by { |r| [ -r[:match_pct], -r[:available_count] ] }
      .first(MAX_RESULTS)

    render json: {
      recipes: ranked,
      meta: {
        total_searched: recipe_ids.size,
        returned: ranked.size,
        query_ingredients: ingredients
      }
    }
  rescue TheMealDbClient::ApiError => e
    render json: { error: { code: 502, message: e.message } }, status: :bad_gateway
  end

  private

  def search_recipes(client, ingredients)
    id_frequency = Hash.new(0)

    ingredients.each do |ingredient|
      results = client.search_by_ingredient(ingredient)
      results.each { |r| id_frequency[r[:id]] += 1 }
    end

    id_frequency
      .sort_by { |_, count| -count }
      .map(&:first)
  end

  def fetch_full_recipes(client, recipe_ids, ingredients)
    matcher = RecipeMatcher.new(ingredients)
    recipes = []

    recipe_ids.each do |id|
      recipe = client.lookup_recipe(id)
      next if recipe.nil?

      match = matcher.match(recipe)
      recipes << recipe if match[:total_ingredients] > 0

      break if recipes.size >= MAX_RESULTS * 2
    end

    recipes
  end
end
