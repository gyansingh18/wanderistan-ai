module Api
  class ChatController < ApplicationController
    protect_from_forgery with: :exception
    before_action :verify_authenticity_token

    def create
      message = params[:message]

      # Process the message using OpenAI
      response = OpenaiService.generate_travel_response(message)

      # Extract locations from the message
      locations = extract_locations(message)

      render json: {
        response: response,
        locations: locations
      }
    rescue => e
      Rails.logger.error "Chat processing error: #{e.message}"
      render json: { error: "An error occurred while processing your message" }, status: :internal_server_error
    end

    private

    def extract_locations(message)
      locations = []

      # Common location patterns
      location_patterns = {
        'tanzania' => [35.7516, -6.3690],
        'zanzibar' => [39.1977, -6.1659],
        'serengeti' => [34.8333, -2.3333],
        'kilimanjaro' => [37.3556, -3.0674],
        'dar es salaam' => [39.2083, -6.7927],
        'arusha' => [36.6827, -3.3869]
      }

      # Check for location mentions in the message
      location_patterns.each do |location, coordinates|
        if message.downcase.include?(location)
          locations << {
            name: location.titleize,
            coordinates: coordinates
          }
        end
      end

      locations
    end
  end
end
