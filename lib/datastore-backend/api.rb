require 'grape'

module Datastore::Backend
  class API < ::Grape::API
    version 'v1', :using => :path, :vendor => 'kntl'

    content_type :json, 'application/json'

    get "version" do
      api.version
    end

    namespace :public do
      get '/:uuid' do
        {}
      end
    end
  end
end