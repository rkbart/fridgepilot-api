require 'rails_helper'

RSpec.describe RecipeMatcher do
  describe '#match' do
    it 'normalizes ingredient names for matching' do
      matcher = described_class.new([ "Chicken", "garlic", " Soy Sauce " ])

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

      expect(result[:total_ingredients]).to eq(4)
      expect(result[:available_count]).to eq(3)
      expect(result[:match_pct]).to eq(75)
      expect(result[:available]).to include("chicken", "Garlic", "soy sauce")
      expect(result[:missing]).to include("bay leaves")
    end

    it 'handles parenthetical info in ingredient names' do
      matcher = described_class.new([ "chicken breast" ])

      recipe = {
        id: "1",
        name: "Test",
        ingredients: [
          { name: "Chicken Breast (boneless)", measure: "500g" }
        ]
      }

      result = matcher.match(recipe)

      expect(result[:match_pct]).to eq(100)
      expect(result[:available_count]).to eq(1)
      expect(result[:missing]).to be_empty
    end

    it 'calculates 0% match when no ingredients available' do
      matcher = described_class.new([ "tofu" ])

      recipe = {
        id: "1",
        name: "Test",
        ingredients: [
          { name: "chicken", measure: "1 kg" },
          { name: "garlic", measure: "3 cloves" }
        ]
      }

      result = matcher.match(recipe)

      expect(result[:match_pct]).to eq(0)
      expect(result[:available_count]).to eq(0)
      expect(result[:missing].length).to eq(2)
    end

    it 'calculates 100% match' do
      matcher = described_class.new([ "chicken", "garlic", "onion" ])

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

      expect(result[:match_pct]).to eq(100)
      expect(result[:available_count]).to eq(3)
      expect(result[:missing]).to be_empty
    end

    it 'handles empty recipe ingredients' do
      matcher = described_class.new([ "chicken" ])

      recipe = {
        id: "1",
        name: "Test",
        ingredients: []
      }

      result = matcher.match(recipe)

      expect(result[:match_pct]).to eq(0)
      expect(result[:total_ingredients]).to eq(0)
    end

    it 'handles nil pantry ingredients gracefully' do
      matcher = described_class.new([ nil, "", "chicken" ])

      recipe = {
        id: "1",
        name: "Test",
        ingredients: [
          { name: "chicken", measure: "1 kg" }
        ]
      }

      result = matcher.match(recipe)

      expect(result[:match_pct]).to eq(100)
    end

    it 'preserves recipe metadata' do
      matcher = described_class.new([ "chicken" ])

      recipe = {
        id: "52772",
        name: "Teriyaki Chicken",
        image_url: "https://example.com/img.jpg",
        category: "Chicken",
        area: "Japanese",
        instructions: "Cook it.",
        youtube_url: "https://youtube.com/watch?v=123",
        tags: [ "Meat", "Dinner" ],
        ingredients: [
          { name: "chicken", measure: "1 kg" }
        ]
      }

      result = matcher.match(recipe)

      expect(result[:id]).to eq("52772")
      expect(result[:name]).to eq("Teriyaki Chicken")
      expect(result[:image_url]).to eq("https://example.com/img.jpg")
      expect(result[:category]).to eq("Chicken")
      expect(result[:area]).to eq("Japanese")
      expect(result[:instructions]).to eq("Cook it.")
      expect(result[:tags]).to eq([ "Meat", "Dinner" ])
    end

    it 'includes measure info in ingredient match results' do
      matcher = described_class.new([ "chicken" ])

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
      expect(chicken_ing[:measure]).to eq("1 kg")
      expect(chicken_ing[:available]).to be true

      garlic_ing = result[:ingredients].find { |i| i[:name] == "garlic" }
      expect(garlic_ing[:available]).to be false
    end
  end
end
