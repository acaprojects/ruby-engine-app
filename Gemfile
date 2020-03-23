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


# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
    # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    gem 'byebug',      platform: :mri
    gem 'web-console', platform: :mri
    gem 'rspec-rails'
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
gem 'ruby-ntlm'

gem 'rbtrace', require: 'rbtrace'
gem 'yajl-ruby', require: 'yajl'
gem 'mono_logger'

# nio4r 2.5.1 caused errors in build
gem 'nio4r', '2.4.0'

# sprockets 4.0.0 requires ruby 2.5.0
gem 'sprockets', '3.7.2'

# faraday 1.0.0+ is a breaking change requiring new instantiation method in all dependant libs
gem 'faraday', '0.17.3'
