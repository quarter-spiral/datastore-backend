require 'rubygems'
require 'bundler/setup'

require 'datastore-backend'
require 'rack/jsonp'

use Rack::JSONP

require 'ping-middleware'
use Ping::Middleware

run Datastore::Backend::API
