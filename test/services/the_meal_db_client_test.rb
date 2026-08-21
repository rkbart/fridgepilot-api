require "test_helper"
require "minitest/mock"

class TheMealDbClientTest < ActiveSupport::TestCase
  setup do
    @client = TheMealDbClient.new
  end

  test "search_by_ingredient returns meals" do
    stub_response = {
      "meals" => [
        { "idMeal" => "52772", "strMeal" => "Teriyaki Chicken Casserole",
          "strMealThumb" => "https://example.com/img.jpg", "strArea" => "Japanese" },
        { "idMeal" => "52874", "strMeal" => "Chicken & Mushroom Hotpot",
          "strMealThumb" => "https://example.com/img2.jpg", "strArea" => "British" }
      ]
    }

    http_mock = Minitest::Mock.new
    http_mock.expect(:request, OpenStruct.new(code: "200", body: stub_response.to_json)) do |req|
      req.is_a?(Net::HTTP::Get)
    end

    Net::HTTP.stub(:new, http_mock) do
      results = @client.search_by_ingredient("chicken")

      assert_equal 2, results.length
      assert_equal "52772", results[0][:id]
      assert_equal "Teriyaki Chicken Casserole", results[0][:name]
    end
  end

  test "search_by_ingredient handles empty results" do
    stub_response = { "meals" => nil }

    http_mock = Minitest::Mock.new
    http_mock.expect(:request, OpenStruct.new(code: "200", body: stub_response.to_json)) do |req|
      req.is_a?(Net::HTTP::Get)
    end

    Net::HTTP.stub(:new, http_mock) do
      results = @client.search_by_ingredient("nonexistent_ingredient_xyz")

      assert_equal [], results
    end
  end

  test "lookup_recipe returns normalized recipe" do
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

    http_mock = Minitest::Mock.new
    http_mock.expect(:request, OpenStruct.new(code: "200", body: stub_response.to_json)) do |req|
      req.is_a?(Net::HTTP::Get)
    end

    Net::HTTP.stub(:new, http_mock) do
      recipe = @client.lookup_recipe("52772")

      assert_equal "52772", recipe[:id]
      assert_equal "Teriyaki Chicken Casserole", recipe[:name]
      assert_equal "Chicken", recipe[:category]
      assert_equal "Japanese", recipe[:area]
      assert_equal 2, recipe[:ingredients].length
      assert_equal "soy sauce", recipe[:ingredients][0][:name]
      assert_equal "3/4 cup", recipe[:ingredients][0][:measure]
      assert_equal ["Meat", "Casserole"], recipe[:tags]
    end
  end

  test "lookup_recipe returns nil for no results" do
    stub_response = { "meals" => nil }

    http_mock = Minitest::Mock.new
    http_mock.expect(:request, OpenStruct.new(code: "200", body: stub_response.to_json)) do |req|
      req.is_a?(Net::HTTP::Get)
    end

    Net::HTTP.stub(:new, http_mock) do
      result = @client.lookup_recipe("99999")

      assert_nil result
    end
  end

  test "raises ApiError on HTTP failure" do
    http_mock = Minitest::Mock.new
    http_mock.expect(:request, OpenStruct.new(code: "500", body: "Server Error")) do |req|
      req.is_a?(Net::HTTP::Get)
    end

    Net::HTTP.stub(:new, http_mock) do
      assert_raises TheMealDbClient::ApiError do
        @client.search_by_ingredient("chicken")
      end
    end
  end

  test "raises ApiError on timeout" do
    http_mock = Minitest::Mock.new
    http_mock.expect(:request, -> { raise Net::OpenTimeout }) do |req|
      req.is_a?(Net::HTTP::Get)
    end

    Net::HTTP.stub(:new, http_mock) do
      assert_raises TheMealDbClient::ApiError do
        @client.search_by_ingredient("chicken")
      end
    end
  end
end
