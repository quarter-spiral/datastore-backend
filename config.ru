require 'rubygems'
require 'bundler/setup'

require 'datastore-backend'
require 'rack/jsonp'

use Rack::JSONP
run Datastore::Backend::API
