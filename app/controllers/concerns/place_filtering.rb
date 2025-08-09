module PlaceFiltering
  extend ActiveSupport::Concern

  private

  def apply_place_filters(places)
    places = places.by_category(params[:category]) if params[:category].present?
    places = places.by_region(params[:region]) if params[:region].present?
    places = apply_search_filter(places) if params[:search].present?
    places
  end

  def apply_search_filter(places)
    places.where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
  end
end
