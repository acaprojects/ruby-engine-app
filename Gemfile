source 'https://rubygems.org'

gem 'rails', '~> 5.0', '>= 5.0.0.1'

# High performance multi-threaded web server
gem 'spider-gazelle', '~> 3.0'

# TODO:: we should package these up as GEMS? Probably only ruby-engine
gem 'orchestrator', path: '../ruby-engine'
gem 'aca-device-modules', path: '../aca-device-modules'

# Database
gem 'couchbase-orm'

# Authentication
gem 'doorkeeper-couchbase'
# gem 'coauth', github: 'QuayPay/coauth', branch: 'couchbase-orm'
gem 'coauth', path: '../coauth'

gem 'xorcist', github: 'aca-labs/xorcist'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
    # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    gem 'byebug',      platform: :mri
    gem 'web-console', platform: :mri
end

group :development do
    gem 'listen', '~> 3.0.5'

    # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
    #gem 'spring'
    #gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'  #, platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'viewpoint2', git: 'https://github.com/aca-labs/viewpoint'
