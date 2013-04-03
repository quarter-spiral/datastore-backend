source 'https://rubygems.org'
source "https://user:We267RFF7BfwVt4LdqFA@privategems.herokuapp.com/"

# Specify your gem's dependencies in datastore-backend.gemspec
gemspec

ruby '1.9.3'

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

  gem 'auth-backend', "~> 0.0.28"
  #gem 'auth-backend', path: '../auth-backend'
  gem 'sqlite3'
  gem 'sinatra_warden', git: 'https://github.com/quarter-spiral/sinatra_warden.git'
  gem 'songkick-oauth2-provider', git: 'https://github.com/quarter-spiral/oauth2-provider.git'
  gem 'nokogiri'
end
