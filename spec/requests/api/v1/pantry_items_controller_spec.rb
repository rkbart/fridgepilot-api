require 'rails_helper'

RSpec.describe Api::V1::PantryItemsController, type: :request do
  let(:user) { create(:user) }
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }

  describe 'POST /api/v1/pantry_items' do
    context 'when a case-insensitive duplicate exists' do
      before { create(:pantry_item, user: user, name: "spaghetti") }

      it 'rejects the item with a validation error' do
        post '/api/v1/pantry_items', params: { pantry_item: { name: "Spaghetti" } }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to include("already been taken")
      end
    end

    context 'when the name differs only by surrounding or repeated whitespace' do
      it 'normalizes and rejects as duplicate' do
        create(:pantry_item, user: user, name: "chicken breast")

        post '/api/v1/pantry_items', params: { pantry_item: { name: "  chicken   breast " } }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when no duplicate exists' do
      it 'creates the item with normalized name' do
        post '/api/v1/pantry_items', params: { pantry_item: { name: "  olive   oil " } }.to_json, headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("olive oil")
      end
    end

    context 'when another user has the same item' do
      it 'allows the item' do
        create(:pantry_item, user: create(:user), name: "Spaghetti")

        post '/api/v1/pantry_items', params: { pantry_item: { name: "spaghetti" } }.to_json, headers: headers

        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PATCH /api/v1/pantry_items/:id' do
    let!(:item) { create(:pantry_item, user: user, name: "rice") }
    let!(:other) { create(:pantry_item, user: user, name: "Rice Noodles") }

    it 'rejects renaming onto an existing duplicate' do
      patch "/api/v1/pantry_items/#{item.id}", params: { pantry_item: { name: "rice noodles" } }.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'allows a unique rename' do
      patch "/api/v1/pantry_items/#{item.id}", params: { pantry_item: { name: "brown rice" } }.to_json, headers: headers

      expect(response).to have_http_status(:success)
      expect(item.reload.name).to eq("brown rice")
    end
  end
end
