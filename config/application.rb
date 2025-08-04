require_relative "boot"

require "rails/all"

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

    # Load environment variables from .env file
    config.before_configuration do
      env_file = File.join(Rails.root, '.env')
      if File.exist?(env_file)
        File.readlines(env_file).each do |line|
          line.strip!
          next if line.empty? || line.start_with?('#')

          key, value = line.split('=', 2)
          next unless key && value

          # Remove quotes if present
          value = value.gsub(/^["']|["']$/, '')
          ENV[key.strip] = value.strip
        end
      end
    end
  end
end
