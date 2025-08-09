class PlacesController < ApplicationController
  include PlaceFiltering

  skip_before_action :authenticate_user!, only: [:index, :show, :explore, :map, :map_data]

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
    @places = apply_place_filters(Place.includes(:videos))
    @categories = Place::CATEGORIES
    @regions = Place::REGIONS
  end

  def map
    @places = Place.all
    @mapbox_token = ENV["MAPBOX_API_KEY"]
  end

  def map_data
    @places = apply_place_filters(Place.includes(:videos))

    render json: @places.map do |place|
      {
        id: place.id,
        name: place.name,
        latitude: place.latitude,
        longitude: place.longitude,
        category: place.category,
        region: place.region,
        description: place.description,
        image_url: place.image_url,
        videos: place.videos.map { |video| {
          id: video.id,
          title: video.title,
          youtube_url: video.youtube_url,
          thumbnail_url: video.thumbnail_url
        }},
        stats: {
          video_count: place.videos.count,
          average_rating: place.average_rating,
          visit_count: place.visit_count
        }
      }
    end
  end


end
