module Datastore
  module Backend
    ROOT = File.dirname(File.expand_path('../', __FILE__))
  end
end

require 'datastore-backend/version'
require 'datastore-backend/data_set'
require 'datastore-backend/api'

ENV['RACK_ENV'] ||= 'development'

Mongoid.logger.level = Logger::WARN
Mongoid.load!(File.expand_path('./config/mongoid.yml', Datastore::Backend::ROOT))