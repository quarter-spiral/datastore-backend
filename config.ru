require 'rubygems'
require 'bundler/setup'

require 'datastore-backend'
require 'rack/jsonp'

use Rack::JSONP

require 'ping-middleware'
use Ping::Middleware

require 'raven'
require 'qs/request/tracker/raven_processor'
Raven.configure do |config|
  config.tags = {'app' => 'auth-backend'}
  config.processors = [Raven::Processor::SanitizeData, Qs::Request::Tracker::RavenProcessor]
end
use Raven::Rack
use Qs::Request::Tracker::Middleware
run Datastore::Backend::API
