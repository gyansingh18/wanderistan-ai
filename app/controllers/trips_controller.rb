class TripsController < ApplicationController
  before_action :authenticate_user!, except: [:planner, :test_openai]
  before_action :set_trip, only: [:show, :edit, :update, :destroy, :add_place, :remove_place]

  def index
    @trips = current_user.trips.order(created_at: :desc)
  end

  def show
    @itinerary_items = @trip.itinerary_items.by_day.includes(:place)

    # Fetch videos for places in the itinerary
    @videos = []
    @trip.places.each do |place|
      place_videos = YoutubeService.fetch_videos_for_place(place.name, 1)
      @videos.concat(place_videos) if place_videos.any?
    end

    # If no place-specific videos, fall back to destination-based videos
    if @videos.empty?
      @videos = YoutubeService.fetch_videos_for_trip(@trip.destination)
    end
  end

  def new
    @trip = current_user.trips.build
  end

  def create
    @trip = current_user.trips.build(trip_params)

    if @trip.save
      redirect_to @trip, notice: 'Trip was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: 'Trip was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_url, notice: 'Trip was successfully deleted.'
  end

  def planner
    # Show the AI trip planner form - no authentication required
    render 'planner_v2'
  end

  def test_openai
    prompt = params[:prompt].presence || "Hi"
    # Use simple chat for the lightweight message UI
    chat_response = OpenaiService.generate_travel_response(prompt)

    if chat_response.present?
      render json: { success: true, data: chat_response }
    else
      render json: { success: false, error: "Failed to generate AI response" }, status: :unprocessable_entity
    end
  end

  def generate_plan
    # Require authentication for generating plans
    unless user_signed_in?
      redirect_to new_user_session_path, alert: 'Please sign in to create trips.'
      return
    end

    # Build structured prompt from form data
    prompt = build_structured_prompt(params)

    if prompt.blank?
      redirect_to planner_path, alert: 'Please fill in the required fields.'
      return
    end

    # Generate AI itinerary
    ai_response = OpenaiService.generate_trip_itinerary(prompt)

    if ai_response
      Rails.logger.info "AI itinerary generated successfully"
    else
      Rails.logger.error "Failed to generate AI itinerary"
      redirect_to planner_path, alert: 'Failed to generate itinerary. Please check your API keys and try again.'
      return
    end

    if ai_response
      # Convert budget breakdown values to numbers
      budget_breakdown = ai_response["budget_breakdown"]&.transform_values do |value|
        if value.is_a?(String)
          # Extract numeric value from currency string (e.g., "₹8,750" -> 8750)
          value.gsub(/[^\d]/, '').to_i
        else
          value.to_i
        end
      end

      # If AI didn't provide budget breakdown, generate realistic one
      if budget_breakdown.blank? || budget_breakdown.empty?
        budget_breakdown = generate_realistic_budget_breakdown_from_params(params)
      end

      # Create trip from AI response
      @trip = current_user.trips.build(
        title: ai_response["title"] || "AI Generated Trip",
        destination: params[:destination] || "Unknown Destination",
        start_date: Date.current + 1.month,
        end_date: Date.current + 1.month + (params[:duration].to_i - 1).days,
        budget: params[:budget].to_i || 50000,
        ai_summary: ai_response["summary"],
        itinerary: ai_response.to_json,
        budget_estimate: ai_response["budget_estimate"],
        budget_breakdown: budget_breakdown,
        money_saving_tips: ai_response["money_saving_tips"]
      )

      if @trip.save
        # Create itinerary items from AI response
        create_itinerary_items_from_ai(@trip, ai_response)
        redirect_to @trip, notice: 'Your AI-generated trip is ready!'
      else
        redirect_to planner_path, alert: 'Failed to create trip. Please try again.'
      end
    else
      redirect_to planner_path, alert: 'Failed to generate itinerary. Please try again.'
    end
  end

  def add_place
    place = Place.find(params[:place_id])
    day = params[:day]&.to_i || @trip.itinerary_items.maximum(:day).to_i + 1

    @trip.add_place(place, day)
    redirect_to @trip, notice: 'Place added to your trip!'
  end

  def remove_place
    place = Place.find(params[:place_id])
    @trip.itinerary_items.where(place: place).destroy_all
    redirect_to @trip, notice: 'Place removed from your trip.'
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(:title, :destination, :start_date, :end_date, :budget, :ai_summary, :itinerary)
  end

  def extract_destination_from_prompt(prompt)
    # Simple extraction - in production, use more sophisticated NLP
    destinations = ['Bali', 'Manali', 'Rishikesh', 'Kerala', 'Sikkim', 'Himachal', 'Europe', 'Bali']
    destinations.find { |dest| prompt.include?(dest) } || 'Unknown Destination'
  end

  def extract_budget_from_prompt(prompt)
    # Extract budget from prompt using regex
    if prompt.match(/\d{1,3}(?:,\d{3})*(?:k|K)/)
      budget_str = prompt.match(/\d{1,3}(?:,\d{3})*(?:k|K)/)[0]
      budget_str.gsub(/[kK]/, '').gsub(',', '').to_i * 1000
    elsif prompt.match(/₹\s*\d+/)
      prompt.match(/₹\s*(\d+)/)[1].to_i
    else
      50000 # Default budget
    end
  end

  def create_itinerary_items_from_ai(trip, ai_response)
    return unless ai_response["itinerary"]

    ai_response["itinerary"].each do |day_data|
      trip.itinerary_items.create!(
        day: day_data["day"],
        title: day_data["title"],
        description: day_data["activities"]&.join(", ")
      )
    end
  end

  def build_structured_prompt(params)
    parts = []

    # Basic details
    parts << "#{params[:duration]} day trip to #{params[:destination]}"

    # Travelers
    adults = params[:adults].to_i
    children = params[:children].to_i
    if adults > 0
      parts << "for #{adults} adult#{adults > 1 ? 's' : ''}"
      if children > 0
        parts << "and #{children} child#{children > 1 ? 'ren' : ''}"
      end
    end

    # Traveler type
    if params[:traveler_type].present?
      traveler_type_map = {
        'family_young' => 'family with young children (stroller-friendly activities)',
        'family_teens' => 'family with teenagers',
        'couple' => 'romantic couple getaway',
        'friends' => 'group of friends',
        'solo' => 'solo traveler',
        'business' => 'business traveler',
        'accessible' => 'accessible travel needs',
        'senior' => 'senior travelers'
      }
      parts << "specifically for #{traveler_type_map[params[:traveler_type]] || params[:traveler_type]}"
    end

    # Travel pace
    if params[:travel_pace].present?
      pace_map = {
        'relaxed' => 'relaxed and leisurely pace',
        'moderate' => 'moderate pace with some downtime',
        'active' => 'fast-paced and active schedule'
      }
      parts << "with #{pace_map[params[:travel_pace]] || params[:travel_pace]}"
    end

    # Budget
    if params[:budget].present? && params[:budget].to_i > 0
      parts << "with a budget of ₹#{params[:budget]} per person"
    end

    # Activities
    if params[:activities].present?
      activities = Array(params[:activities])
      activity_map = {
        'hiking' => 'hiking and trekking',
        'beaches' => 'beaches and water sports',
        'museums' => 'museums and cultural sites',
        'nightlife' => 'nightlife and entertainment',
        'foodie' => 'food and dining experiences',
        'shopping' => 'shopping and retail',
        'adventure' => 'adventure sports and activities',
        'wildlife' => 'wildlife and nature experiences',
        'spiritual' => 'spiritual and wellness activities'
      }
      mapped_activities = activities.map { |a| activity_map[a] || a }
      parts << "including #{mapped_activities.join(', ')}"
    end

    # Accommodation style
    if params[:accommodation].present?
      accommodation_map = {
        'luxury' => 'luxury accommodations',
        'midrange' => 'mid-range hotels',
        'budget' => 'budget-friendly accommodations',
        'boutique' => 'boutique hotels and unique stays'
      }
      parts << "preferring #{accommodation_map[params[:accommodation]] || params[:accommodation]}"
    end

    # Dietary preferences
    if params[:dietary].present?
      dietary = Array(params[:dietary])
      if dietary.any?
        parts << "with #{dietary.join(', ')} dietary preferences"
      end
    end

    # What to avoid
    if params[:avoid].present?
      parts << "avoiding #{params[:avoid]}"
    end

    # Special requirements
    if params[:special_requirements].present?
      parts << "with special requirements: #{params[:special_requirements]}"
    end

    # Additional notes
    if params[:notes].present?
      parts << "Additional notes: #{params[:notes]}"
    end

    # Final prompt
    prompt = parts.join(" • ")
    prompt += ". Please provide a detailed day-by-day itinerary with specific activities, estimated costs, accommodation suggestions, and local experiences tailored to the traveler profile."
    prompt += " Include budget breakdown by category, money-saving tips, and alternative options for each day."

    prompt
  end

  private

  def generate_realistic_budget_breakdown_from_params(params)
    destination = params[:destination]&.downcase
    total_budget = params[:budget].to_i
    duration = params[:duration].to_i

    # Determine destination type and generate realistic breakdown
    if international_destination?(destination)
      generate_international_budget(total_budget, duration)
    elsif domestic_destination?(destination)
      generate_domestic_budget(total_budget, duration)
    else
      generate_local_budget(total_budget, duration)
    end
  end

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
