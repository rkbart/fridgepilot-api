require 'rails_helper'

RSpec.describe TheMealDbClient do
  subject(:client) { described_class.new }

  describe '#search_by_ingredient' do
    it 'returns normalized meals for a valid ingredient' do
      stub_response = {
        "meals" => [
          { "idMeal" => "52772", "strMeal" => "Teriyaki Chicken Casserole",
            "strMealThumb" => "https://example.com/img.jpg", "strArea" => "Japanese" },
          { "idMeal" => "52874", "strMeal" => "Chicken & Mushroom Hotpot",
            "strMealThumb" => "https://example.com/img2.jpg", "strArea" => "British" }
        ]
      }

      http_mock = instance_double(Net::HTTP)
      response_mock = instance_double(Net::HTTPResponse, code: "200", body: stub_response.to_json)

      allow(Net::HTTP).to receive(:new).and_return(http_mock)
      allow(http_mock).to receive(:use_ssl=)
      allow(http_mock).to receive(:open_timeout=)
      allow(http_mock).to receive(:read_timeout=)
      allow(http_mock).to receive(:request).and_return(response_mock)

      results = client.search_by_ingredient("chicken")

      expect(results.length).to eq(2)
      expect(results[0][:id]).to eq("52772")
      expect(results[0][:name]).to eq("Teriyaki Chicken Casserole")
    end

    it 'returns empty array when no meals found' do
      stub_response = { "meals" => nil }

      http_mock = instance_double(Net::HTTP)
      response_mock = instance_double(Net::HTTPResponse, code: "200", body: stub_response.to_json)

      allow(Net::HTTP).to receive(:new).and_return(http_mock)
      allow(http_mock).to receive(:use_ssl=)
      allow(http_mock).to receive(:open_timeout=)
      allow(http_mock).to receive(:read_timeout=)
      allow(http_mock).to receive(:request).and_return(response_mock)

      results = client.search_by_ingredient("nonexistent_ingredient_xyz")

      expect(results).to eq([])
    end
  end

  describe '#lookup_recipe' do
    it 'returns normalized recipe with ingredients and metadata' do
      stub_response = {
        "meals" => [
          {
            "idMeal" => "52772",
            "strMeal" => "Teriyaki Chicken Casserole",
            "strMealThumb" => "https://example.com/img.jpg",
            "strCategory" => "Chicken",
            "strArea" => "Japanese",
            "strInstructions" => "Preheat oven.",
            "strYoutube" => "https://youtube.com/watch?v=123",
            "strTags" => "Meat,Casserole",
            "strIngredient1" => "soy sauce",
            "strIngredient2" => "water",
            "strIngredient3" => "",
            "strMeasure1" => "3/4 cup",
            "strMeasure2" => "1/2 cup",
            "strMeasure3" => ""
          }
        ]
      }

      http_mock = instance_double(Net::HTTP)
      response_mock = instance_double(Net::HTTPResponse, code: "200", body: stub_response.to_json)

      allow(Net::HTTP).to receive(:new).and_return(http_mock)
      allow(http_mock).to receive(:use_ssl=)
      allow(http_mock).to receive(:open_timeout=)
      allow(http_mock).to receive(:read_timeout=)
      allow(http_mock).to receive(:request).and_return(response_mock)

      recipe = client.lookup_recipe("52772")

      expect(recipe[:id]).to eq("52772")
      expect(recipe[:name]).to eq("Teriyaki Chicken Casserole")
      expect(recipe[:category]).to eq("Chicken")
      expect(recipe[:area]).to eq("Japanese")
      expect(recipe[:ingredients].length).to eq(2)
      expect(recipe[:ingredients][0][:name]).to eq("soy sauce")
      expect(recipe[:ingredients][0][:measure]).to eq("3/4 cup")
      expect(recipe[:tags]).to eq(["Meat", "Casserole"])
    end

    it 'returns nil when no meals found' do
      stub_response = { "meals" => nil }

      http_mock = instance_double(Net::HTTP)
      response_mock = instance_double(Net::HTTPResponse, code: "200", body: stub_response.to_json)

      allow(Net::HTTP).to receive(:new).and_return(http_mock)
      allow(http_mock).to receive(:use_ssl=)
      allow(http_mock).to receive(:open_timeout=)
      allow(http_mock).to receive(:read_timeout=)
      allow(http_mock).to receive(:request).and_return(response_mock)

      result = client.lookup_recipe("99999")

      expect(result).to be_nil
    end
  end

  describe 'error handling' do
    it 'raises ApiError on HTTP failure' do
      http_mock = instance_double(Net::HTTP)
      response_mock = instance_double(Net::HTTPResponse, code: "500", body: "Server Error")

      allow(Net::HTTP).to receive(:new).and_return(http_mock)
      allow(http_mock).to receive(:use_ssl=)
      allow(http_mock).to receive(:open_timeout=)
      allow(http_mock).to receive(:read_timeout=)
      allow(http_mock).to receive(:request).and_return(response_mock)

      expect { client.search_by_ingredient("chicken") }.to raise_error(TheMealDbClient::ApiError)
    end

    it 'raises ApiError on timeout' do
      http_mock = instance_double(Net::HTTP)

      allow(Net::HTTP).to receive(:new).and_return(http_mock)
      allow(http_mock).to receive(:use_ssl=)
      allow(http_mock).to receive(:open_timeout=)
      allow(http_mock).to receive(:read_timeout=)
      allow(http_mock).to receive(:request).and_raise(Net::OpenTimeout)

      expect { client.search_by_ingredient("chicken") }.to raise_error(TheMealDbClient::ApiError)
    end
  end
end
