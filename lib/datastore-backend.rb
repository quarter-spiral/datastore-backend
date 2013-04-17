module Datastore
  module Backend
    ROOT = File.dirname(File.expand_path('../', __FILE__))
  end
end

require 'cache-client'
require 'cache-backend-iron-cache'

require 'datastore-backend/version'
require 'datastore-backend/data_set'
require 'datastore-backend/connection'
require 'datastore-backend/api'

ENV['RACK_ENV'] ||= 'development'

Mongoid.logger.level = Logger::WARN

# Path to the mongoig config file passed in for embedded purposes
mongo_config_path = ENV['DATASTORE_BACKEND_MONGOID_CONFIG']
# Default path to the mongoid config
mongo_config_path ||= File.expand_path('./config/mongoid.yml', Datastore::Backend::ROOT)

Mongoid.load!(mongo_config_path)
