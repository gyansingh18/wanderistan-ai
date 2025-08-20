class Place < ApplicationRecord
  has_many :videos, dependent: :destroy
  has_many :itinerary_items, dependent: :destroy
  has_many :trips, through: :itinerary_items

  validates :name, presence: true
  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }
  validates :region, presence: true
  validates :category, presence: true

  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_region, ->(region) { where(region: region) }

  CATEGORIES = %w[Beach Mountain City Temple Museum Restaurant Adventure Cultural Historical].freeze
  REGIONS = %w[North India South India East India West India Central India Himalayas Coastal].freeze

  def coordinates
    [latitude, longitude]
  end

  def map_url
    "https://www.google.com/maps?q=#{latitude},#{longitude}"
  end

  def featured_videos
    videos.limit(3)
  end
end
