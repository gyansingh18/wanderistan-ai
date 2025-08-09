class VideosController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :country_videos, :place_videos, :preview]

  def index
    @videos = Video.all
  end

  def show
    @video = Video.find(params[:id])
  end

  def country_videos
    if params[:country].present?
      # Fetch videos for a specific country
      country = params[:country]
      videos = YoutubeService.fetch_videos_for_country(country, 6)

      render json: {
        country: country,
        videos: videos,
        count: videos.length
      }
    else
      # Return list of countries with video stats
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
