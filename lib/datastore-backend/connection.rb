module Datastore::Backend
  class Connection
    attr_reader :auth, :cache

    def self.create
      self.new(
        ENV['QS_AUTH_BACKEND_URL'] || 'http://auth-backend.dev'
      )
    end

    def initialize(auth_backend_url)
      @cache = ::Cache::Client.new(::Cache::Backend::IronCache, ENV['IRON_CACHE_PROJECT_ID'], ENV['IRON_CACHE_TOKEN'], ENV['IRON_CACHE_CACHE'])
      @auth = Auth::Client.new(auth_backend_url, cache: @cache)
    end
  end
end
