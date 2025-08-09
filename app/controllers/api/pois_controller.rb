module Api
  class PoisController < ApplicationController
    def index
      bounds = params[:bounds].split(',').map(&:to_f)
      @pois = Poi.verified
                 .by_type(params[:type])
                 .in_bounds(bounds[1], bounds[0], bounds[3], bounds[2])
                 .limit(100)

      render json: {
        type: 'FeatureCollection',
        features: @pois.map(&:as_geojson)
      }
    end

    def show
      @poi = Poi.find(params[:id])
      render json: @poi.as_geojson
    end

    def search
      @pois = Poi.verified
                 .where('name ILIKE ?', "%#{params[:query]}%")
                 .limit(5)

      render json: @pois.map { |poi| {
        id: poi.id,
        text: poi.name,
        type: poi.type_name,
        coordinates: poi.coordinates
      }}
    end

    def near_route
      coordinates = params[:coordinates]
      pois = []

      coordinates.each_cons(2) do |start, finish|
        # Find POIs near each segment of the route
        mid_lat = (start[1] + finish[1]) / 2
        mid_lng = (start[0] + finish[0]) / 2

        segment_pois = Poi.verified
                         .search_near(mid_lat, mid_lng)
                         .by_type(params[:type])
                         .limit(10)

        pois.concat(segment_pois)
      end

      render json: {
        type: 'FeatureCollection',
        features: pois.uniq.map(&:as_geojson)
      }
    end
  end
end
