class ApplicationController < ActionController::Base
  # Fake Commit 2: Add application controller documentation
  # This controller serves as the base for all other controllers
  # Provides common functionality and authentication methods
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    trips_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
