require 'rails_helper'

RSpec.describe Api::V1::RecipesController, type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }

  describe 'POST /api/v1/recipes/import' do
    context 'when not authenticated' do
      it 'returns unauthorized' do
        post '/api/v1/recipes/import', params: { meal_id: "52772" }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with blank meal_id' do
      it 'returns unprocessable entity' do
        post '/api/v1/recipes/import', params: { meal_id: "" }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to eq("meal_id is required")
      end
    end

    context 'with valid meal_id' do
      it 'imports the recipe from TheMealDB' do
        client_mock = instance_double(TheMealDbClient)

        allow(TheMealDbClient).to receive(:new).and_return(client_mock)
        allow(client_mock).to receive(:lookup_recipe).with("52772").and_return({
          id: "52772", name: "Teriyaki Chicken", image_url: "https://img.com/tc.jpg",
          category: "Chicken", area: "Japanese",
          instructions: "Step one.\r\nStep two.\r\n\r\nStep three.",
          youtube_url: "https://youtube.com/watch?v=abc", tags: ["Meat"],
          ingredients: [
            { name: "chicken", measure: "1 kg" },
            { name: "soy sauce", measure: "4 tbsp" },
            { name: "sugar", measure: "2" }
          ]
        })

        post '/api/v1/recipes/import', params: { meal_id: "52772" }.to_json, headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Teriyaki Chicken")
        expect(json["image_url"]).to eq("https://img.com/tc.jpg")
        expect(json["ingredients"]).to eq([
          { "name" => "chicken", "quantity" => 1.0, "unit" => "kg" },
          { "name" => "soy sauce", "quantity" => 4.0, "unit" => "tbsp" },
          { "name" => "sugar", "quantity" => 2.0, "unit" => nil }
        ])
        expect(json["instructions"]).to eq(["Step one.", "Step two.", "Step three."])

        recipe = user.recipes.last
        expect(recipe.source).to eq("themealdb:52772")
      end
    end

    context 'when TheMealDB returns nil' do
      it 'returns not found' do
        client_mock = instance_double(TheMealDbClient)

        allow(TheMealDbClient).to receive(:new).and_return(client_mock)
        allow(client_mock).to receive(:lookup_recipe).with("99999").and_return(nil)

        post '/api/v1/recipes/import', params: { meal_id: "99999" }.to_json, headers: headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to eq("Recipe not found on TheMealDB")
      end
    end

    context 'when TheMealDB API errors' do
      it 'returns bad gateway' do
        client_mock = instance_double(TheMealDbClient)

        allow(TheMealDbClient).to receive(:new).and_return(client_mock)
        allow(client_mock).to receive(:lookup_recipe)
          .and_raise(TheMealDbClient::ApiError, "Service unavailable")

        post '/api/v1/recipes/import', params: { meal_id: "52772" }.to_json, headers: headers

        expect(response).to have_http_status(:bad_gateway)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to eq("Service unavailable")
      end
    end
  end
end
