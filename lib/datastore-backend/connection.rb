module Datastore::Backend
  class Connection
    attr_reader :auth

    def self.create
      self.new(
        ENV['QS_AUTH_BACKEND_URL'] || 'http://auth-backend.dev'
      )
    end

    def initialize(auth_backend_url)
      @auth = Auth::Client.new(auth_backend_url)
    end
  end
end
