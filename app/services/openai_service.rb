require 'openai'

class OpenaiService
  class << self
    def generate_travel_response(message)
      return missing_key_message unless openai_key_present?

      client = OpenAI::Client.new(access_token: fetch_openai_key)

      response = client.chat(
        parameters: {
          model: default_model,
          messages: [
            { role: "system", content: "You are a helpful AI travel planner. Provide concise, practical travel advice and recommendations in PLAIN TEXT. Do not use any markdown symbols (no **bold**, no # headings, no code blocks). Use simple sentences and bullet points with the bullet character • when listing items. When the user asks about a destination, explicitly mention the main destination once using its common country or city name (for example: Sri Lanka, Paris, Tokyo). If you propose a multi-stop itinerary, add ONE optional line at the end starting with ROUTE: followed by ordered stops and transport between them in brackets, e.g., ROUTE: Colombo -[train]-> Kandy -[bus]-> Sigiriya -[hike]-> Ella -[bus]-> Galle. Keep it single-line plain text." },
            { role: "user", content: message }
          ],
          temperature: 0.7,
          max_tokens: 500
        }
      )

      response.dig("choices", 0, "message", "content")
    rescue => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      generic_error_message
    end

    # More structured trip generator used by planner actions
    def generate_trip_itinerary(prompt)
      return { "summary" => missing_key_message } unless openai_key_present?

      client = OpenAI::Client.new(access_token: fetch_openai_key)
      response = client.chat(
        parameters: {
          model: default_model,
          messages: [
            { role: "system", content: trip_planner_system_prompt },
            { role: "user", content: prompt }
          ],
          temperature: 0.7,
          max_tokens: 1200
        }
      )

      content = response.dig("choices", 0, "message", "content")
      parse_itinerary_json(content)
    rescue => e
      Rails.logger.error "OpenAI API Error (itinerary): #{e.message}"
      nil
    end

    private

    def default_model
      ENV.fetch('OPENAI_MODEL', 'gpt-4o-mini')
    end

    def trip_planner_system_prompt
      "You are an expert travel planner. Return concise JSON with keys: title, summary, itinerary (array of days with day, title, activities), budget_estimate, budget_breakdown, money_saving_tips. Do not include markdown."
    end

    def parse_itinerary_json(content)
      # Try to parse JSON if present; if plain text, wrap minimal structure
      begin
        json_start = content.index('{')
        json_end = content.rindex('}')
        json = content[json_start..json_end]
        JSON.parse(json)
      rescue
        { "summary" => content }
      end
    end

    def openai_key_present?
      fetch_openai_key.present?
    end

    def fetch_openai_key
      ENV['OPENAI_API_KEY'].presence || Rails.application.credentials.dig(:openai, :api_key)
    end

    def missing_key_message
      "OpenAI API key is missing. Please set OPENAI_API_KEY in your environment."
    end

    def generic_error_message
      "Unable to process your request at the moment. Please try again later."
    end
  end
end
