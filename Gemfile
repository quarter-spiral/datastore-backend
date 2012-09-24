source 'https://rubygems.org'

# Specify your gem's dependencies in datastore-backend.gemspec
gemspec

platforms :rbx do
  gem 'bson_ext'
end

platform :ruby do
  gem 'thin'
end

group :development, :test do
  gem 'rack-client'
  gem 'rspec', '~> 2.10.0'
  gem 'guard-rspec'
  gem 'ruby_gntp'
  gem 'rake'
end
