require "test_helper"

class RecipeMatcherTest < ActiveSupport::TestCase
  test "normalizes ingredient names" do
    matcher = RecipeMatcher.new(["Chicken", "garlic", " Soy Sauce "])

    recipe = {
      id: "1",
      name: "Test Recipe",
      ingredients: [
        { name: "chicken", measure: "1 kg" },
        { name: "Garlic", measure: "3 cloves" },
        { name: "soy sauce", measure: "4 tbsp" },
        { name: "bay leaves", measure: "2" }
      ]
    }

    result = matcher.match(recipe)

    assert_equal 4, result[:total_ingredients]
    assert_equal 3, result[:available_count]
    assert_equal 75, result[:match_pct]
    assert_includes result[:available], "chicken"
    assert_includes result[:available], "Garlic"
    assert_includes result[:available], "soy sauce"
    assert_includes result[:missing], "bay leaves"
  end

  test "handles parenthetical info in ingredient names" do
    matcher = RecipeMatcher.new(["chicken breast"])

    recipe = {
      id: "1",
      name: "Test",
      ingredients: [
        { name: "Chicken Breast (boneless)", measure: "500g" }
      ]
    }

    result = matcher.match(recipe)

    assert_equal 100, result[:match_pct]
    assert_equal 1, result[:available_count]
    assert_empty result[:missing]
  end

  test "calculates 0% match when no ingredients available" do
    matcher = RecipeMatcher.new(["tofu"])

    recipe = {
      id: "1",
      name: "Test",
      ingredients: [
        { name: "chicken", measure: "1 kg" },
        { name: "garlic", measure: "3 cloves" }
      ]
    }

    result = matcher.match(recipe)

    assert_equal 0, result[:match_pct]
    assert_equal 0, result[:available_count]
    assert_equal 2, result[:missing].length
  end

  test "calculates 100% match" do
    matcher = RecipeMatcher.new(["chicken", "garlic", "onion"])

    recipe = {
      id: "1",
      name: "Test",
      ingredients: [
        { name: "chicken", measure: "1 kg" },
        { name: "garlic", measure: "3 cloves" },
        { name: "onion", measure: "1" }
      ]
    }

    result = matcher.match(recipe)

    assert_equal 100, result[:match_pct]
    assert_equal 3, result[:available_count]
    assert_empty result[:missing]
  end

  test "handles empty recipe ingredients" do
    matcher = RecipeMatcher.new(["chicken"])

    recipe = {
      id: "1",
      name: "Test",
      ingredients: []
    }

    result = matcher.match(recipe)

    assert_equal 0, result[:match_pct]
    assert_equal 0, result[:total_ingredients]
  end

  test "handles nil pantry ingredients gracefully" do
    matcher = RecipeMatcher.new([nil, "", "chicken"])

    recipe = {
      id: "1",
      name: "Test",
      ingredients: [
        { name: "chicken", measure: "1 kg" }
      ]
    }

    result = matcher.match(recipe)

    assert_equal 100, result[:match_pct]
  end

  test "preserves recipe metadata" do
    matcher = RecipeMatcher.new(["chicken"])

    recipe = {
      id: "52772",
      name: "Teriyaki Chicken",
      image_url: "https://example.com/img.jpg",
      category: "Chicken",
      area: "Japanese",
      instructions: "Cook it.",
      youtube_url: "https://youtube.com/watch?v=123",
      tags: ["Meat", "Dinner"],
      ingredients: [
        { name: "chicken", measure: "1 kg" }
      ]
    }

    result = matcher.match(recipe)

    assert_equal "52772", result[:id]
    assert_equal "Teriyaki Chicken", result[:name]
    assert_equal "https://example.com/img.jpg", result[:image_url]
    assert_equal "Chicken", result[:category]
    assert_equal "Japanese", result[:area]
    assert_equal "Cook it.", result[:instructions]
    assert_equal ["Meat", "Dinner"], result[:tags]
  end

  test "ingredient match includes measure info" do
    matcher = RecipeMatcher.new(["chicken"])

    recipe = {
      id: "1",
      name: "Test",
      ingredients: [
        { name: "chicken", measure: "1 kg" },
        { name: "garlic", measure: "3 cloves" }
      ]
    }

    result = matcher.match(recipe)

    chicken_ing = result[:ingredients].find { |i| i[:name] == "chicken" }
    assert_equal "1 kg", chicken_ing[:measure]
    assert_equal true, chicken_ing[:available]

    garlic_ing = result[:ingredients].find { |i| i[:name] == "garlic" }
    assert_equal false, garlic_ing[:available]
  end
end
