Dropbox::Sign.configure do |config|
    config.username = Rails.application.credentials.dropbox_sign_api_key
end
