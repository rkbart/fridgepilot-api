require 'rails_helper'

RSpec.describe Api::V1::DiscoverController, type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }

  describe 'POST /api/v1/discover' do
    context 'when not authenticated' do
      it 'returns unauthorized' do
        post '/api/v1/discover', params: { ingredients: [ "chicken" ] }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with empty ingredients' do
      it 'returns empty results' do
        post '/api/v1/discover', params: { ingredients: [] }.to_json, headers: headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["recipes"]).to eq([])
        expect(json["meta"]["returned"]).to eq(0)
      end
    end

    context 'with valid ingredients' do
      it 'returns recipes with match scores' do
        client_mock = instance_double(TheMealDbClient)

        allow(TheMealDbClient).to receive(:new).and_return(client_mock)
        allow(client_mock).to receive(:search_by_ingredient).with("chicken").and_return([
          { id: "52772", name: "Teriyaki Chicken", thumbnail: "img.jpg", area: "Japanese" }
        ])
        allow(client_mock).to receive(:lookup_recipe).with("52772").and_return({
          id: "52772", name: "Teriyaki Chicken", image_url: "img.jpg",
          category: "Chicken", area: "Japanese", instructions: "Cook it.",
          youtube_url: nil, tags: nil,
          ingredients: [
            { name: "chicken", measure: "1 kg" },
            { name: "soy sauce", measure: "4 tbsp" }
          ]
        })

        post '/api/v1/discover', params: { ingredients: [ "chicken" ] }.to_json, headers: headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["recipes"].length).to eq(1)
        expect(json["recipes"][0]["name"]).to eq("Teriyaki Chicken")
        expect(json["recipes"][0]["match_pct"]).to eq(50)
        expect(json["recipes"][0]["total_ingredients"]).to eq(2)
        expect(json["recipes"][0]["available_count"]).to eq(1)
      end
    end

    context 'when TheMealDB API errors' do
      it 'returns bad gateway' do
        client_mock = instance_double(TheMealDbClient)

        allow(TheMealDbClient).to receive(:new).and_return(client_mock)
        allow(client_mock).to receive(:search_by_ingredient)
          .and_raise(TheMealDbClient::ApiError, "Service unavailable")

        post '/api/v1/discover', params: { ingredients: [ "chicken" ] }.to_json, headers: headers

        expect(response).to have_http_status(:bad_gateway)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to eq("Service unavailable")
      end
    end
  end
end
