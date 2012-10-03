ENV['RACK_ENV'] ||= 'test'

Bundler.require

require 'datastore-backend'
require 'auth-backend'

require 'rack/client'

Dir[File.expand_path('../support/*.rb', __FILE__)].each {|f| require f}

RSpec.configure do |config|
end
