module PlacesHelper
  def category_icon(category)
    case category
    when 'Beach'
      'fas fa-umbrella-beach'
    when 'Mountain'
      'fas fa-mountain'
    when 'City'
      'fas fa-city'
    when 'Temple'
      'fas fa-pray'
    when 'Museum'
      'fas fa-landmark'
    when 'Restaurant'
      'fas fa-utensils'
    when 'Adventure'
      'fas fa-hiking'
    when 'Cultural'
      'fas fa-theater-masks'
    when 'Historical'
      'fas fa-monument'
    else
      'fas fa-map-marker-alt'
    end
  end

  def region_icon(region)
    case region
    when 'North India'
      'fas fa-snowflake'
    when 'South India'
      'fas fa-sun'
    when 'East India'
      'fas fa-sunrise'
    when 'West India'
      'fas fa-sunset'
    when 'Central India'
      'fas fa-compass'
    when 'Himalayas'
      'fas fa-mountain'
    when 'Coastal'
      'fas fa-water'
    else
      'fas fa-map-marker-alt'
    end
  end

  def place_video_count(place)
    count = place.videos.count
    if count == 0
      "No videos"
    elsif count == 1
      "1 video"
    else
      "#{count} videos"
    end
  end

  def place_rating_stars(rating = nil)
    return "No rating" unless rating

    stars = ""
    5.times do |i|
      if i < rating
        stars += '<i class="fas fa-star text-warning"></i>'
      else
        stars += '<i class="far fa-star text-muted"></i>'
      end
    end
    stars.html_safe
  end

  def category_color(category)
    colors = {
      'beach' => '#17a2b8',      # Cyan
      'mountain' => '#6c757d',   # Gray
      'city' => '#dc3545',       # Red
      'temple' => '#ffc107',     # Yellow
      'museum' => '#6610f2',     # Purple
      'restaurant' => '#fd7e14',  # Orange
      'adventure' => '#6f42c1',  # Purple
      'cultural' => '#fd7e14',   # Orange
      'historical' => '#6610f2'  # Purple
    }
    colors[category.to_s.downcase] || '#007bff' # Default to blue
  end

  def category_class(category)
    classes = {
      'beach' => 'info',
      'mountain' => 'secondary',
      'city' => 'danger',
      'temple' => 'warning',
      'museum' => 'primary',
      'restaurant' => 'warning',
      'adventure' => 'primary',
      'cultural' => 'warning',
      'historical' => 'primary'
    }
    classes[category.to_s.downcase] || 'primary'
  end
end
