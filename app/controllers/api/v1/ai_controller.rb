require "net/http"

class Api::V1::AiController < Api::V1::BaseController
  def suggest_recipes
    pantry_items = current_user.pantry_items.select(:name).map { |i| { name: i.name } }

    if pantry_items.empty?
      return render json: {
        suggestions: [],
        message: "Add items to your pantry first to get recipe suggestions."
      }
    end

    service = AiService.new(user: current_user)
    suggestions = service.suggest_recipes(pantry_items: pantry_items)

    render json: { suggestions: suggestions }
  rescue AiRateLimitError => e
    render json: {
      error: { code: 429, message: e.message },
      suggestions: [],
      rate_limited: true
    }, status: :too_many_requests
  rescue AiAuthError => e
    render json: {
      error: { code: 401, message: e.message },
      suggestions: []
    }, status: :unauthorized
  rescue AiError => e
    render json: {
      error: { code: 503, message: "AI service unavailable. Please try again later." },
      suggestions: []
    }, status: :service_unavailable
  rescue StandardError
    render json: {
      error: { code: 500, message: "Unexpected error. Please try again." },
      suggestions: []
    }, status: :internal_server_error
  end

  def generate_grocery_list
    recipe_id = params[:recipe_id]
    recipe = current_user.recipes.find(recipe_id)

    pantry_items = current_user.pantry_items.select(:name).map { |i| { name: i.name } }

    service = AiService.new(user: current_user)
    ai_items = service.generate_grocery_list(
      recipe: { name: recipe.name, ingredients: recipe.ingredients },
      pantry_items: pantry_items
    )

    list = current_user.grocery_lists.create!(
      name: "#{recipe.name} - Grocery List",
      source: "ai_generated"
    )

    ai_items.each do |item|
      list.grocery_items.create!(
        name: item[:name],
        quantity: item[:quantity],
        unit: item[:unit],
        source: "ai_suggested",
        status: "pending",
        recipe: recipe
      )
    end

    render json: GroceryListSerializer.new(list).serializable_hash, status: :created
  rescue AiRateLimitError => e
    render json: {
      error: { code: 429, message: e.message },
      rate_limited: true
    }, status: :too_many_requests
  rescue AiAuthError => e
    render json: { error: { code: 401, message: e.message } }, status: :unauthorized
  rescue AiError
    render json: { error: { code: 503, message: "AI service unavailable." } }, status: :service_unavailable
  end
end
