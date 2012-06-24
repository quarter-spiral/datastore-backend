module Datastore::Backend
  class API < Grape::API
    version 'v1', :using => :path, :vendor => 'kntl'

    namespace :public do
    end
  end
end