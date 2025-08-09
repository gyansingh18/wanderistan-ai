Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users

  # Root route
  root "home#index"


  # Trips
  resources :trips do
    member do
      post :add_place
      delete :remove_place
    end
  end

  # AI Trip Planner
  get '/ai-planner', to: 'trips#planner', as: :planner
  post '/ai-planner', to: 'trips#generate_plan'

  # Explore routes
  get '/explore', to: 'places#explore', as: :explore
  get '/explore/map', to: 'places#map', as: :explore_map

  # Places routes
  resources :places, only: [:index, :show] do
    collection do
      get :map_data
    end
  end

  # Videos routes
  resources :videos, only: [:index, :create]
  get 'videos/country/:country', to: 'videos#country_videos'
  get 'videos/place/:place', to: 'videos#place_videos'
  get 'videos/preview/:location', to: 'videos#preview'
  get 'videos/search/:location', to: 'videos#search_videos'

  # API namespace
  namespace :api do
    resources :pois, only: [:index, :show] do
      collection do
        get :search
        post :near_route
      end
    end

    resources :weather, only: [:index] do
      collection do
        post :route
      end
    end

    resources :offline_maps, only: [:create]
    resources :border_crossings, only: [:create]
  end
end
