class Poi < ApplicationRecord
  # Constants
  TYPES = %w[hostel camping trail food cultural].freeze
  BACKPACKER_TYPES = %w[food stay experience transport].freeze

  # Validations
  validates :name, presence: true
  validates :poi_type, presence: true, inclusion: { in: TYPES }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :by_type, ->(type) { where(poi_type: type) }
  scope :in_bounds, ->(sw_lat, sw_lng, ne_lat, ne_lng) {
    where(
      latitude: sw_lat..ne_lat,
      longitude: sw_lng..ne_lng
    )
  }
  scope :popular, -> { order(likes_count: :desc) }
  scope :top_rated, -> { where.not(rating: nil).order(rating: :desc) }
  scope :budget_friendly, -> { where.not(price: nil).order(price: :asc) }

  # Class methods
  def self.types_for_select
    (TYPES + BACKPACKER_TYPES).uniq.map { |type| [type.titleize, type] }
  end

  def self.search_near(lat, lng, radius_km = 5)
    # Rough approximation: 1 degree = 111km
    degree_change = radius_km / 111.0

    where(
      latitude: (lat - degree_change)..(lat + degree_change),
      longitude: (lng - degree_change)..(lng + degree_change)
    )
  end

  # Instance methods
  def coordinates
    [longitude, latitude]
  end

  def type_name
    poi_type.titleize
  end

  def price_range
    return nil if price.nil?

    case price
    when 0..500 then '₹'
    when 501..1500 then '₹₹'
    else '₹₹₹'
    end
  end

  def as_geojson
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: coordinates
      },
      properties: {
        id: id,
        name: name,
        type: poi_type,
        description: description,
        price: price,
        rating: rating,
        price_range: price_range,
        amenities: amenities,
        opening_hours: opening_hours,
        contact_info: contact_info,
        website: website,
        verified: verified
      }
    }
  end
end
