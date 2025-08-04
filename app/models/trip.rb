class Trip < ApplicationRecord
  belongs_to :user
  has_many :itinerary_items, dependent: :destroy
  has_many :places, through: :itinerary_items

  validates :title, presence: true
  validates :destination, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :budget, presence: true, numericality: { greater_than: 0 }
  validate :end_date_after_start_date

  scope :upcoming, -> { where('start_date > ?', Date.current) }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }

  def duration_days
    (end_date - start_date).to_i + 1
  end

  def total_cost
    # Calculate from budget breakdown if available
    if budget_breakdown.present?
      budget_breakdown.values.sum { |v| v.to_s.gsub(/[^\d]/, '').to_i }
    else
      budget * 0.85 # Default 85% of budget
    end
  end

  def savings
    budget - total_cost
  end

  def budget_breakdown
    return {} unless self[:budget_breakdown].present?

    breakdown = if self[:budget_breakdown].is_a?(String)
      JSON.parse(self[:budget_breakdown])
    else
      self[:budget_breakdown]
    end

    # Convert currency strings to numbers for display
    breakdown.transform_values do |value|
      if value.is_a?(String)
        # Extract numeric value from currency string (e.g., "₹8,750" -> 8750)
        value.gsub(/[^\d]/, '').to_i
      else
        value.to_i
      end
    end
  rescue JSON::ParserError
    {}
  end

  def money_saving_tips
    return [] unless self[:money_saving_tips].present?

    if self[:money_saving_tips].is_a?(String)
      JSON.parse(self[:money_saving_tips])
    else
      self[:money_saving_tips]
    end
  rescue JSON::ParserError
    []
  end

  def add_place(place, day = nil)
    day ||= itinerary_items.maximum(:day).to_i + 1
    itinerary_items.create!(place: place, day: day, title: "Visit #{place.name}")
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
