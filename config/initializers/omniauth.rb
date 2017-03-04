require 'omniauth'

Rails.application.config.session_store :cookie_store, key: '_engine_app_session'
::OmniAuthConfig = proc {

    # NOTE:: You should replace this with a valid authentication service
    provider :developer unless Rails.env.production?
}
