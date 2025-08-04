class VideosController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :country_videos, :place_videos, :preview]

  def index
    @videos = Video.all
  end

  def show
    @video = Video.find(params[:id])
  end

  def country_videos
    country = params[:country]

    # Fetch videos for the country using YouTube API
    videos = YoutubeService.fetch_videos_for_country(country, 6)

    render json: {
      country: country,
      videos: videos,
      count: videos.length
    }
  end

  def place_videos
    place_name = params[:place]

    # Fetch videos for the specific place
    videos = YoutubeService.fetch_videos_for_place(place_name, 4)

    render json: {
      place: place_name,
      videos: videos,
      count: videos.length
    }
  end

  def preview
    location = params[:location]
    type = params[:type] || 'place'

    # Fetch a single featured video for preview
    video = YoutubeService.get_featured_video_for_location(location, type)

    render json: {
      location: location,
      type: type,
      video: video
    }
  end

  def search_videos
    location = params[:location]
    max_results = params[:max_results]&.to_i || 3

    # Use the new VideoSearchService to get relevant videos
    videos = VideoSearchService.search_videos_for_location(location, max_results)

    render json: {
      location: location,
      videos: videos,
      count: videos.length,
      search_query: "#{location} travel guide"
    }
  end
end
