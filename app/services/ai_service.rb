class AiService
  BASE_URL = "https://integrate.api.nvidia.com/v1"

  def initialize(user:)
    @user = user
    @api_key = user.ai_api_key.presence || ENV.fetch("NIM_API_KEY", "")
    @model = "meta/llama-3.1-8b-instruct"
  end

  def suggest_recipes(pantry_items:)
    prompt = build_recipe_prompt(pantry_items)
    response = call_api(prompt)
    parse_recipe_suggestions(response, pantry_items)
  end

  def generate_grocery_list(recipe:, pantry_items:)
    prompt = build_grocery_prompt(recipe, pantry_items)
    response = call_api(prompt)
    parse_grocery_items(response)
  end

  private

  def call_api(prompt)
    uri = URI("#{BASE_URL}/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      model: @model,
      messages: [ { role: "user", content: prompt } ],
      max_tokens: 1024,
      temperature: 0.7
    }.to_json

    response = http.request(request)
    handle_response(response)
  end

  def handle_response(response)
    case response.code.to_i
    when 200
      JSON.parse(response.body)
    when 429
      raise AiRateLimitError, "AI service rate limited. Please try again later."
    when 401
      raise AiAuthError, "Invalid API key. Please check your settings."
    else
      raise AiError, "AI service error (#{response.code}): #{response.body}"
    end
  end

  def build_recipe_prompt(pantry_items)
    items_list = pantry_items.map { |i| i[:name] }.join(", ")
    <<~PROMPT
      Given these pantry items: #{items_list}

      Suggest 3 simple recipes. For each recipe provide:
      - name
      - ingredients (list each ingredient)
      - match_score (0.0 to 1.0, how many ingredients are in the pantry)
      - missing_ingredients (ingredients not in the pantry)

      Return JSON array with format:
      [{"name": "...", "ingredients": [...], "match_score": 0.8, "missing_ingredients": [...]}]
    PROMPT
  end

  def build_grocery_prompt(recipe, pantry_items)
    pantry_names = pantry_items.map { |i| i[:name].downcase }
    ingredient_names = recipe[:ingredients].map { |i| i.is_a?(Hash) ? (i["name"] || i[:name]) : i }
    <<~PROMPT
      Recipe: #{recipe[:name]}
      Ingredients: #{ingredient_names.join(", ")}
      Already in pantry: #{pantry_names.join(", ")}

      List only the ingredients needed that are NOT in the pantry.
      Return JSON array: [{"name": "...", "quantity": "...", "unit": "..."}]
    PROMPT
  end

  def parse_recipe_suggestions(response, pantry_items)
    content = response.dig("choices", 0, "message", "content") || "[]"
    json_str = extract_json(content)
    suggestions = JSON.parse(json_str)

    suggestions.map do |s|
      {
        name: s["name"],
        ingredients: s["ingredients"] || [],
        match_score: (s["match_score"] || 0).to_f,
        missing_ingredients: s["missing_ingredients"] || []
      }
    end
  rescue JSON::ParserError
    []
  end

  def parse_grocery_items(response)
    content = response.dig("choices", 0, "message", "content") || "[]"
    json_str = extract_json(content)
    items = JSON.parse(json_str)

    items.map do |item|
      {
        name: item["name"],
        quantity: item["quantity"],
        unit: item["unit"]
      }
    end
  rescue JSON::ParserError
    []
  end

  def extract_json(text)
    match = text.match(/\[[\s\S]*\]/)
    match ? match[0] : "[]"
  end
end

class AiError < StandardError; end
class AiRateLimitError < AiError; end
class AiAuthError < AiError; end
