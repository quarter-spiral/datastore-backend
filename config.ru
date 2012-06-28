require 'rubygems'
require 'bundler'

Bundler.require

require 'datastore-backend'
require 'rack/jsonp'

use Rack::JSONP
run Datastore::Backend::API