Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  devise_scope :user do
    post 'users/token/renew', to: 'users/tokens#renew'
  end

  # API namespace
  namespace :api do
    namespace :v1 do
      # Current user
      get 'me', to: 'me#show'
      # Recipe endpoints
      resources :recipes, only: [:index, :show, :create, :update, :destroy]

      # Pantry endpoints
      resources :pantry_items, only: [:index, :show, :create, :update, :destroy]

      # Grocery list endpoints
      resources :grocery_lists, only: [:index, :show, :create, :update, :destroy] do
        resources :items, only: [:create, :update, :destroy], controller: 'grocery_items'
      end

      # AI endpoints
      post 'ai/suggest_recipes', to: 'ai#suggest_recipes'
      post 'ai/generate_grocery_list', to: 'ai#generate_grocery_list'

      # User settings
      get 'settings', to: 'settings#show'
      put 'settings', to: 'settings#update'
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
