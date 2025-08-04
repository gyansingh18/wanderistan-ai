class OpenaiService
  include HTTParty

  OPENAI_API_KEY = ENV["OPENAI_ACCESS_TOKEN"]
  OPENAI_ENDPOINT = "https://api.openai.com/v1/chat/completions"

  def self.generate_trip_itinerary(prompt)
    return nil unless OPENAI_API_KEY.present?

    # Enhanced prompt with AI-powered budget breakdown
    enhanced_prompt = <<~PROMPT
      Create a detailed travel itinerary based on this request: "#{prompt}"

      Please provide a structured response with:
      1. A catchy title for the trip
      2. A brief summary (2-3 sentences)
      3. Detailed day-by-day itinerary with:
         - Specific activities and timings
         - Estimated costs for each day
         - Recommended places to visit
         - Local experiences and hidden gems
      4. AI-generated realistic budget breakdown by category based on the destination:
         - Analyze the destination type (international/domestic/local)
         - Consider typical costs for that specific location
         - Provide realistic estimates for each category
         - Ensure the breakdown adds up to the total budget
      5. Money-saving tips and budget-friendly alternatives specific to the destination
      6. Estimated total cost vs budget

      Format the response as JSON with this structure:
      {
        "title": "Trip Title",
        "summary": "Brief description",
        "budget_estimate": "Total estimated cost",
        "budget_breakdown": {
          "flights": "amount",
          "accommodation": "amount",
          "food": "amount",
          "activities": "amount",
          "transportation": "amount"
        },
        "money_saving_tips": ["tip1", "tip2", "tip3"],
        "itinerary": [
          {
            "day": 1,
            "title": "Day Title",
            "activities": ["activity1", "activity2"],
            "places": ["place1", "place2"],
            "estimated_cost": "daily cost",
            "budget_tips": "specific tips for this day"
          }
        ]
      }

      IMPORTANT BUDGET GUIDELINES:
      - For international destinations (Bali, Thailand, Singapore, etc.):
        * Flights: 50-70% of budget (₹15,000-35,000 for 2 people)
        * Accommodation: 20-30% (₹2,000-8,000 per night)
        * Food: 8-12% (₹500-1,500 per person per day)
        * Activities: 8-15% (₹1,000-3,000 per day)
        * Local Transport: 2-5% (₹200-1,000 per day)

      - For domestic destinations (Manali, Goa, Kerala, etc.):
        * Flights/Travel: 25-40% of budget (₹3,000-15,000 for 2 people)
        * Accommodation: 30-45% (₹1,500-5,000 per night)
        * Food: 15-25% (₹300-1,200 per person per day)
        * Activities: 15-25% (₹500-2,500 per day)
        * Local Transport: 5-10% (₹200-800 per day)

      - For local destinations (same city/state):
        * Accommodation: 40-60% of budget
        * Food: 20-30% (local food costs)
        * Activities: 20-30% (local attractions)
        * Local Transport: 5-10%

      Always provide realistic estimates based on the specific destination and ensure the breakdown adds up to the total budget.
    PROMPT

    response = HTTParty.post(
      OPENAI_ENDPOINT,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OPENAI_API_KEY}"
      },
      body: {
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are an expert travel planner specializing in budget-friendly, personalized itineraries. Always provide realistic cost estimates and practical money-saving advice."
          },
          {
            role: "user",
            content: enhanced_prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 2000
      }.to_json
    )

    return nil unless response.code == 200

    begin
      content = response["choices"][0]["message"]["content"]
      JSON.parse(content)
    rescue JSON::ParserError
      # Fallback to simple text parsing if JSON fails
      {
        "title" => "AI Generated Trip",
        "summary" => content,
        "budget_estimate" => "₹25,000",
        "budget_breakdown" => {
          "flights" => "₹12,000",
          "accommodation" => "₹7,500",
          "food" => "₹2,500",
          "activities" => "₹2,000",
          "transportation" => "₹1,000"
        },
        "money_saving_tips" => [
          "Book flights in advance for better rates",
          "Stay in local guesthouses or budget hotels",
          "Eat at local restaurants and street food",
          "Use public transportation when possible",
          "Book activities in advance for discounts"
        ],
        "itinerary" => []
      }
    end
  end

  def self.generate_place_description(place_name, region)
    return nil unless OPENAI_API_KEY.present?

    response = HTTParty.post(
      OPENAI_ENDPOINT,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OPENAI_API_KEY}"
      },
      body: {
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are a travel writer. Write a compelling 2-3 sentence description of the given place, highlighting its unique features and attractions."
          },
          {
            role: "user",
            content: "Write a description for #{place_name} in #{region}."
          }
        ],
        temperature: 0.8,
        max_tokens: 150
      }.to_json
    )

    return nil unless response.code == 200

    response["choices"][0]["message"]["content"]
  end
end
