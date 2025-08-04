class PlacesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :explore, :map, :map_data, :country_videos]

  def index
    @q = Place.ransack(params[:q])
    @places = @q.result(distinct: true).includes(:videos)
    @categories = Place::CATEGORIES
    @regions = Place::REGIONS
  end

  def show
    @place = Place.find(params[:id])
    @videos = @place.videos
    @related_places = Place.where(region: @place.region).where.not(id: @place.id).limit(3)
  end

  def explore
    @places = Place.includes(:videos)
    @categories = Place::CATEGORIES
    @regions = Place::REGIONS

    if params[:category].present?
      @places = @places.by_category(params[:category])
    end

    if params[:region].present?
      @places = @places.by_region(params[:region])
    end
  end

  def map
    @places = Place.all
    @mapbox_token = ENV["MAPBOX_API_KEY"]
  end

  def map_data
    @places = Place.all
    render json: @places.map do |place|
      {
        id: place.id,
        name: place.name,
        latitude: place.latitude,
        longitude: place.longitude,
        category: place.category,
        region: place.region,
        description: place.description
      }
    end
  end

  def country_videos
    # Sample country video data - in a real app, this would come from a database
    countries = [
      { name: 'India', latitude: 20.5937, longitude: 78.9629, video_count: 5, category: 'cultural' },
      { name: 'France', latitude: 46.2276, longitude: 2.2137, video_count: 4, category: 'cultural' },
      { name: 'Italy', latitude: 41.8719, longitude: 12.5674, video_count: 3, category: 'cultural' },
      { name: 'Japan', latitude: 36.2048, longitude: 138.2529, video_count: 6, category: 'cultural' },
      { name: 'Australia', latitude: -25.2744, longitude: 133.7751, video_count: 4, category: 'adventure' },
      { name: 'United States', latitude: 39.8283, longitude: -98.5795, video_count: 8, category: 'mixed' },
      { name: 'United Kingdom', latitude: 55.3781, longitude: -3.4360, video_count: 4, category: 'cultural' },
      { name: 'Canada', latitude: 56.1304, longitude: -106.3468, video_count: 3, category: 'nature' },
      { name: 'Brazil', latitude: -14.2350, longitude: -51.9253, video_count: 5, category: 'adventure' },
      { name: 'South Africa', latitude: -30.5595, longitude: 22.9375, video_count: 4, category: 'wildlife' }
    ]

    render json: countries
  end
end
