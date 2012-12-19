require 'rubygems'
require 'bundler/setup'

require 'datastore-backend'
require 'rack/jsonp'
require 'newrelic_rpm'
require 'new_relic/agent/instrumentation/rack'
require 'ping-middleware'

use Rack::JSONP

class NewRelicMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  end
  include NewRelic::Agent::Instrumentation::Rack
end

use NewRelicMiddleware
use Ping::Middleware

run Datastore::Backend::API
