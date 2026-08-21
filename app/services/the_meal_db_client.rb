class TheMealDbClient
  BASE_URL = "https://www.themealdb.com/api/json/v1/1"

  class ApiError < StandardError; end

  def search_by_ingredient(ingredient)
    normalized = ingredient.to_s.strip.gsub(/\s+/, "_")
    data = get("/filter.php", { i: normalized })
    return [] if data["meals"].nil?

    data["meals"].map do |meal|
      {
        id: meal["idMeal"],
        name: meal["strMeal"],
        thumbnail: meal["strMealThumb"],
        area: meal["strArea"]
      }
    end
  end

  def lookup_recipe(meal_id)
    data = get("/lookup.php", { i: meal_id })
    return nil if data["meals"].nil?

    meal = data["meals"].first
    normalize_full_meal(meal)
  end

  def random_recipe
    data = get("/random.php")
    return nil if data["meals"].nil?

    normalize_full_meal(data["meals"].first)
  end

  private

  def get(path, params = {})
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params) if params.any?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    case response.code.to_i
    when 200
      JSON.parse(response.body)
    else
      raise ApiError, "TheMealDB error (#{response.code})"
    end
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    raise ApiError, "TheMealDB request failed: #{e.message}"
  end

  def normalize_full_meal(meal)
    ingredients = (1..20).filter_map do |i|
      name = meal["strIngredient#{i}"]
      measure = meal["strMeasure#{i}"]
      next if name.nil? || name.strip.empty?

      { name: name.strip, measure: measure.to_s.strip }
    end

    {
      id: meal["idMeal"].to_s,
      name: meal["strMeal"],
      image_url: meal["strMealThumb"],
      category: meal["strCategory"],
      area: meal["strArea"],
      instructions: meal["strInstructions"],
      youtube_url: meal["strYoutube"],
      tags: meal["strTags"]&.split(",")&.map(&:strip),
      ingredients: ingredients
    }
  end
end
