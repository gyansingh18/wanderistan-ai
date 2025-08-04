class ItineraryItem < ApplicationRecord
  belongs_to :trip
  belongs_to :place, optional: true

  validates :day, presence: true, numericality: { greater_than: 0 }
  validates :title, presence: true

  scope :by_day, -> { order(:day) }

  def day_label
    "Day #{day}"
  end
end
