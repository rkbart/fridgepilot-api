require "test_helper"
require "minitest/mock"

class Api::V1::DiscoverControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil).first
    @headers = { "Authorization" => "Bearer #{@token}", "Content-Type" => "application/json" }
  end

  test "requires authentication" do
    post "/api/v1/discover", params: { ingredients: ["chicken"] }.to_json,
         headers: { "Content-Type" => "application/json" }

    assert_response :unauthorized
  end

  test "returns empty results for empty ingredients" do
    post "/api/v1/discover", params: { ingredients: [] }.to_json, headers: @headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal [], json["recipes"]
    assert_equal 0, json["meta"]["returned"]
  end

  test "returns recipes with match scores" do
    client_mock = Minitest::Mock.new
    client_mock.expect(:search_by_ingredient, [
      { id: "52772", name: "Teriyaki Chicken", thumbnail: "img.jpg", area: "Japanese" }
    ], ["chicken"])
    client_mock.expect(:lookup_recipe, {
      id: "52772", name: "Teriyaki Chicken", image_url: "img.jpg",
      category: "Chicken", area: "Japanese", instructions: "Cook it.",
      youtube_url: nil, tags: nil,
      ingredients: [
        { name: "chicken", measure: "1 kg" },
        { name: "soy sauce", measure: "4 tbsp" }
      ]
    }, ["52772"])

    TheMealDbClient.stub(:new, client_mock) do
      post "/api/v1/discover", params: { ingredients: ["chicken"] }.to_json, headers: @headers

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json["recipes"].length
      assert_equal "Teriyaki Chicken", json["recipes"][0]["name"]
      assert_equal 50, json["recipes"][0]["match_pct"]
      assert_equal 2, json["recipes"][0]["total_ingredients"]
      assert_equal 1, json["recipes"][0]["available_count"]
    end
  end

  test "handles TheMealDB API errors" do
    client_mock = Minitest::Mock.new
    client_mock.expect(:search_by_ingredient,
                        ->(_arg) { raise TheMealDbClient::ApiError, "Service unavailable" },
                        ["chicken"])

    TheMealDbClient.stub(:new, client_mock) do
      post "/api/v1/discover", params: { ingredients: ["chicken"] }.to_json, headers: @headers

      assert_response :bad_gateway
      json = JSON.parse(response.body)
      assert_equal "Service unavailable", json["error"]["message"]
    end
  end
end
