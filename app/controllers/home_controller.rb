class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @featured_places = Place.featured.limit(6)
    @trending_trips = Trip.joins(:user).limit(3).order(created_at: :desc)
    @categories = Place::CATEGORIES
    @regions = Place::REGIONS
  end
end
