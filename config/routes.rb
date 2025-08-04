Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for authentication
  devise_for :users

  # Root route
  root "home#index"

  # Trip routes
  resources :trips do
    member do
      post :add_place
      delete :remove_place
    end
  end

  # AI Trip Planner
  get 'planner', to: 'trips#planner'
  post 'planner', to: 'trips#generate_plan'

  # Places routes
  resources :places, only: [:index, :show] do
    collection do
      get :explore
      get :map_data
    end
  end

  # Videos routes
  resources :videos, only: [:index, :create]

  # Explore routes
  get 'explore', to: 'places#explore'
  get 'explore/map', to: 'places#map'

  # Video endpoints for map
  get 'videos/country/:country', to: 'videos#country_videos'
  get 'videos/place/:place', to: 'videos#place_videos'
  get 'videos/preview/:location', to: 'videos#preview'
  get 'videos/search/:location', to: 'videos#search_videos'

  # API routes for AJAX calls
  get 'api/places', to: 'places#map_data'
  get 'api/country-videos', to: 'places#country_videos'

  # Test routes
  post 'test_openai_api', to: 'trips#test_openai'

  namespace :api do
    resources :trips, only: [:create, :update] do
      member do
        post :add_place
      end
    end
  end
end
