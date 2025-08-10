require_relative "boot"

require "rails/all"

# Load dotenv only in development or test environment
if ['development', 'test'].include? ENV['RAILS_ENV']
  require 'dotenv'
  # Load root .env first (preferred), then config/<env>.env as fallback
  root_env = File.expand_path('../../.env', __FILE__)
  env_file = File.expand_path("../#{Rails.env}.env", __FILE__)
  Dotenv.load(root_env) if File.exist?(root_env)
  Dotenv.load(env_file) if File.exist?(env_file)
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wanderistan
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
