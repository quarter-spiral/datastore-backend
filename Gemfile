source 'https://rubygems.org'

# Specify your gem's dependencies in datastore-backend.gemspec
gemspec

gem 'grape', '0.2.0'
gem 'mongoid', '2.4.11'
gem 'rack-jsonp-middleware', '0.0.5'

platforms :rbx do
  gem 'bson_ext'
end

group :development, :test do
  gem 'rack-client'
  gem 'rspec', '~> 2.10.0'
  gem 'uuid'
  gem 'guard-rspec'
  gem 'ruby_gntp'
  gem 'rake'
end
