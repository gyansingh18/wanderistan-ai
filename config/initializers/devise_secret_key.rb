Devise.setup do |config|
  config.secret_key = Rails.application.credentials.secret_key_base
end
