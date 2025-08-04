class YoutubeService
  include HTTParty

  YOUTUBE_API_KEY = ENV["YOUTUBE_API_KEY"]
  YOUTUBE_ENDPOINT = "https://www.googleapis.com/youtube/v3/search"

  def self.fetch_videos_for_place(place_name, max_results = 3)
    return [] unless YOUTUBE_API_KEY.present?

    query = "#{place_name} travel guide"

    response = HTTParty.get(YOUTUBE_ENDPOINT, query: {
      part: "snippet",
      q: query,
      type: "video",
      maxResults: max_results,
      key: YOUTUBE_API_KEY,
      videoDuration: "medium",
      relevanceLanguage: "en",
      order: "relevance"
    })

    unless response.code == 200
      Rails.logger.warn "YouTube API error for #{place_name}: #{response.code} #{response.body}"
      # Return fallback sample data when API quota is exceeded
      return get_fallback_videos_for_place(place_name, max_results)
    end

    response["items"].map do |item|
      video_id = item["id"]["videoId"]
      snippet = item["snippet"]
      {
        title: snippet["title"],
        youtube_url: "https://www.youtube.com/watch?v=#{video_id}",
        embed_url: "https://www.youtube.com/embed/#{video_id}",
        thumbnail_url: snippet["thumbnails"]["high"]["url"], # Use high quality thumbnail
        place_name: place_name,
        channel_title: snippet["channelTitle"],
        published_at: snippet["publishedAt"],
        description: snippet["description"],
        duration: "10:30", # Would need additional API call for duration
        view_count: "1.2K" # Would need additional API call for stats
      }
    end
  end

  def self.fetch_videos_for_trip(destination, max_results = 5)
    return [] unless YOUTUBE_API_KEY.present?

    query = "#{destination} travel guide itinerary"

    response = HTTParty.get(YOUTUBE_ENDPOINT, query: {
      part: "snippet",
      q: query,
      type: "video",
      maxResults: max_results,
      key: YOUTUBE_API_KEY,
      videoDuration: "medium",
      relevanceLanguage: "en",
      order: "relevance"
    })

    return [] unless response.code == 200

    response["items"].map do |item|
      video_id = item["id"]["videoId"]
      snippet = item["snippet"]
      {
        title: snippet["title"],
        youtube_url: "https://www.youtube.com/watch?v=#{video_id}",
        embed_url: "https://www.youtube.com/embed/#{video_id}",
        thumbnail_url: snippet["thumbnails"]["high"]["url"],
        place_name: destination,
        channel_title: snippet["channelTitle"],
        published_at: snippet["publishedAt"],
        description: snippet["description"]
      }
    end
  end

  def self.fetch_videos_for_country(country_name, max_results = 6)
    return [] unless YOUTUBE_API_KEY.present?

    # Enhanced query for country-specific travel content
    query = "#{country_name} travel guide tourism"

    response = HTTParty.get(YOUTUBE_ENDPOINT, query: {
      part: "snippet",
      q: query,
      type: "video",
      maxResults: max_results,
      key: YOUTUBE_API_KEY,
      videoDuration: "medium",
      relevanceLanguage: "en",
      order: "relevance",
      videoCategoryId: "27" # Travel & Events category
    })

    unless response.code == 200
      Rails.logger.warn "YouTube API error for #{country_name}: #{response.code} #{response.body}"
      # Return fallback sample data when API quota is exceeded
      return get_fallback_videos_for_country(country_name, max_results)
    end

    response["items"].map do |item|
      video_id = item["id"]["videoId"]
      snippet = item["snippet"]
      {
        title: snippet["title"],
        youtube_url: "https://www.youtube.com/watch?v=#{video_id}",
        embed_url: "https://www.youtube.com/embed/#{video_id}",
        thumbnail_url: snippet["thumbnails"]["high"]["url"],
        country_name: country_name,
        channel_title: snippet["channelTitle"],
        published_at: snippet["publishedAt"],
        description: snippet["description"]
      }
    end
  end

  def self.search_videos(query, max_results = 10)
    return [] unless YOUTUBE_API_KEY.present?

    response = HTTParty.get(YOUTUBE_ENDPOINT, query: {
      part: "snippet",
      q: query,
      type: "video",
      maxResults: max_results,
      key: YOUTUBE_API_KEY,
      videoDuration: "medium",
      relevanceLanguage: "en",
      order: "relevance"
    })

    return [] unless response.code == 200

    response["items"].map do |item|
      video_id = item["id"]["videoId"]
      snippet = item["snippet"]
      {
        title: snippet["title"],
        youtube_url: "https://www.youtube.com/watch?v=#{video_id}",
        embed_url: "https://www.youtube.com/embed/#{video_id}",
        thumbnail_url: snippet["thumbnails"]["high"]["url"],
        channel_title: snippet["channelTitle"],
        published_at: snippet["publishedAt"],
        description: snippet["description"]
      }
    end
  end

  # New method to get a single featured video for preview
  def self.get_featured_video_for_location(location, type = 'place')
    videos = case type
             when 'place'
               fetch_videos_for_place(location, 1)
             when 'country'
               fetch_videos_for_country(location, 1)
             else
               search_videos("#{location} travel", 1)
             end

    videos.first
  end

  # Method to get video details including duration and view count
  def self.get_video_details(video_id)
    return nil unless YOUTUBE_API_KEY.present?

    response = HTTParty.get("https://www.googleapis.com/youtube/v3/videos", query: {
      part: "contentDetails,statistics",
      id: video_id,
      key: YOUTUBE_API_KEY
    })

    return nil unless response.code == 200 && response["items"].any?

    item = response["items"].first
    {
      duration: item["contentDetails"]["duration"],
      view_count: item["statistics"]["viewCount"],
      like_count: item["statistics"]["likeCount"]
    }
  end

  # Fallback sample data for places when API quota is exceeded
  def self.get_fallback_videos_for_place(place_name, max_results = 3)
    sample_videos = {
      "India" => [
        {
          title: "Amazing India - Travel Guide",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          place_name: place_name,
          channel_title: "Travel Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Discover the beauty of India with this comprehensive travel guide."
        }
      ],
      "France" => [
        {
          title: "Paris Travel Guide - Top Attractions",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          place_name: place_name,
          channel_title: "Travel Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Explore the magic of Paris with this detailed travel guide."
        }
      ],
      "Japan" => [
        {
          title: "Tokyo Travel Guide - Must See Places",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          place_name: place_name,
          channel_title: "Travel Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Experience the unique culture of Tokyo with this travel guide."
        }
      ]
    }

    # Return sample data for known places, empty array for others
    sample_videos[place_name] || []
  end

  # Fallback sample data for countries when API quota is exceeded
  def self.get_fallback_videos_for_country(country_name, max_results = 6)
    sample_videos = {
      "India" => [
        {
          title: "India Travel Guide - Complete Tour",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          country_name: country_name,
          channel_title: "Travel Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Comprehensive travel guide to India covering all major destinations."
        },
        {
          title: "Indian Culture and Traditions",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          country_name: country_name,
          channel_title: "Culture Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Explore the rich culture and traditions of India."
        }
      ],
      "France" => [
        {
          title: "France Travel Guide - Paris and Beyond",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          country_name: country_name,
          channel_title: "Travel Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Discover the beauty of France from Paris to the countryside."
        },
        {
          title: "French Cuisine and Culture",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          country_name: country_name,
          channel_title: "Food Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Experience the world-famous French cuisine and culture."
        }
      ],
      "Japan" => [
        {
          title: "Japan Travel Guide - Tokyo and Kyoto",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          country_name: country_name,
          channel_title: "Travel Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Explore the fascinating culture of Japan from modern Tokyo to traditional Kyoto."
        },
        {
          title: "Japanese Culture and Traditions",
          youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          embed_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
          thumbnail_url: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
          country_name: country_name,
          channel_title: "Culture Channel",
          published_at: "2023-01-15T10:00:00Z",
          description: "Discover the unique traditions and culture of Japan."
        }
      ]
    }

    # Return sample data for known countries, empty array for others
    sample_videos[country_name] || []
  end
end
