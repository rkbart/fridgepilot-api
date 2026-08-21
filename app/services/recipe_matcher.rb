class RecipeMatcher
  def initialize(pantry_ingredients)
    @pantry = build_pantry_set(pantry_ingredients)
  end

  def match(recipe)
    recipe_ingredients = recipe[:ingredients] || []
    available = []
    missing = []

    recipe_ingredients.each do |ing|
      normalized = normalize_name(ing[:name])
      if @pantry.include?(normalized)
        available << { name: ing[:name], measure: ing[:measure], available: true }
      else
        missing << { name: ing[:name], measure: ing[:measure], available: false }
      end
    end

    total = recipe_ingredients.length
    match_pct = total > 0 ? (available.length.to_f / total * 100).round : 0

    {
      id: recipe[:id],
      name: recipe[:name],
      image_url: recipe[:image_url],
      category: recipe[:category],
      area: recipe[:area],
      instructions: recipe[:instructions],
      youtube_url: recipe[:youtube_url],
      tags: recipe[:tags],
      match_pct: match_pct,
      total_ingredients: total,
      available_count: available.length,
      ingredients: available + missing,
      available: available.map { |i| i[:name] },
      missing: missing.map { |i| i[:name] }
    }
  end

  private

  def build_pantry_set(ingredients)
    Array(ingredients).filter_map { |name| normalize_name(name) }.uniq.to_set
  end

  def normalize_name(name)
    return nil if name.nil?

    name.to_s
      .downcase
      .strip
      .gsub(/\s*\([^)]*\)\s*/, " ")
      .gsub(/[^a-z0-9\s]/i, "")
      .gsub(/\s+/, " ")
      .strip
  end
end
