module TripsHelper
  def trip_status(trip)
    if trip.start_date > Date.current
      'upcoming'
    elsif trip.end_date < Date.current
      'past'
    else
      'current'
    end
  end

  def trip_status_badge(trip)
    if trip.start_date > Date.current
      'bg-primary'
    elsif trip.end_date < Date.current
      'bg-secondary'
    else
      'bg-success'
    end
  end

  def trip_status_text(trip)
    if trip.start_date > Date.current
      'Upcoming'
    elsif trip.end_date < Date.current
      'Completed'
    else
      'Current'
    end
  end

  def trip_duration_display(trip)
    days = (trip.end_date - trip.start_date).to_i + 1
    "#{days} day#{days > 1 ? 's' : ''}"
  end

  def format_currency(amount)
    number_with_delimiter(amount.to_i)
  end

  def budget_category_icon(category)
    icons = {
      'flights' => 'plane',
      'accommodation' => 'bed',
      'food' => 'utensils',
      'activities' => 'mountain',
      'transportation' => 'car'
    }
    icons[category] || 'circle'
  end

  def budget_category_color(category)
    colors = {
      'flights' => 'primary',
      'accommodation' => 'info',
      'food' => 'warning',
      'activities' => 'success',
      'transportation' => 'secondary'
    }
    colors[category] || 'muted'
  end

  def budget_category_name(category)
    names = {
      'flights' => 'Flights',
      'accommodation' => 'Accommodation',
      'food' => 'Food & Dining',
      'activities' => 'Activities',
      'transportation' => 'Transportation'
    }
    names[category] || category.titleize
  end

  def generate_realistic_budget_breakdown(trip)
    destination = trip.destination&.downcase
    total_budget = trip.budget.to_i
    duration = (trip.end_date - trip.start_date).to_i + 1

    # Determine destination type and generate realistic breakdown
    if international_destination?(destination)
      generate_international_budget(total_budget, duration)
    elsif domestic_destination?(destination)
      generate_domestic_budget(total_budget, duration)
    else
      generate_local_budget(total_budget, duration)
    end
  end

  private

  def international_destination?(destination)
    international_destinations = ['bali', 'thailand', 'singapore', 'malaysia', 'dubai', 'europe', 'usa', 'uk', 'australia', 'japan', 'korea', 'china', 'vietnam', 'cambodia', 'laos', 'myanmar', 'philippines', 'indonesia', 'sri lanka', 'nepal', 'bhutan', 'maldives']
    international_destinations.any? { |dest| destination&.include?(dest) }
  end

  def domestic_destination?(destination)
    domestic_destinations = ['manali', 'rishikesh', 'goa', 'kerala', 'sikkim', 'varanasi', 'jaipur', 'udaipur', 'jodhpur', 'jaisalmer', 'agra', 'varanasi', 'amritsar', 'shimla', 'darjeeling', 'ooty', 'munnar', 'alleppey', 'kumarakom', 'thekkady', 'wayanad', 'coorg', 'mysore', 'bangalore', 'mumbai', 'delhi', 'kolkata', 'chennai', 'hyderabad', 'pune', 'ahmedabad', 'surat', 'vadodara', 'indore', 'bhopal', 'lucknow', 'kanpur', 'nagpur', 'patna', 'ranchi', 'bhubaneswar', 'guwahati', 'imphal', 'aizawl', 'kohima', 'itanagar', 'shillong', 'gangtok', 'leh', 'srinagar', 'jammu', 'chandigarh', 'dehradun', 'haridwar', 'rishikesh', 'mussoorie', 'nainital', 'ranikhet', 'almora', 'pithoragarh', 'chamoli', 'rudraprayag', 'tehri', 'uttarkashi', 'pauri', 'bageshwar', 'champawat', 'udham singh nagar']
    domestic_destinations.any? { |dest| destination&.include?(dest) }
  end

  def generate_international_budget(total_budget, duration)
    {
      'flights' => (total_budget * 0.60).to_i,
      'accommodation' => (total_budget * 0.25).to_i,
      'food' => (total_budget * 0.10).to_i,
      'activities' => (total_budget * 0.03).to_i,
      'transportation' => (total_budget * 0.02).to_i
    }
  end

  def generate_domestic_budget(total_budget, duration)
    {
      'flights' => (total_budget * 0.35).to_i,
      'accommodation' => (total_budget * 0.35).to_i,
      'food' => (total_budget * 0.20).to_i,
      'activities' => (total_budget * 0.08).to_i,
      'transportation' => (total_budget * 0.02).to_i
    }
  end

  def generate_local_budget(total_budget, duration)
    {
      'flights' => 0,
      'accommodation' => (total_budget * 0.50).to_i,
      'food' => (total_budget * 0.25).to_i,
      'activities' => (total_budget * 0.20).to_i,
      'transportation' => (total_budget * 0.05).to_i
    }
  end
end
