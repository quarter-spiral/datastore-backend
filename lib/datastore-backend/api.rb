require 'grape'

module Datastore::Backend
  class API < ::Grape::API
    version 'v1', :using => :path, :vendor => 'kntl'

    format :json
    default_format :json

    rescue_from Mongoid::Errors::Validations
    rescue_from Mongoid::Errors::DocumentNotFound do
      Rack::Response.new([ JSON.dump({error: 'Not found'}) ], 404, { "Content-type" => "application/json" }).finish
    end
    error_format :json

    helpers do
      def payload
        JSON.parse(request.body.string)
      end
    end

    before do
      header('Access-Control-Allow-Origin', request.env['HTTP_ORIGIN'] || '*')
    end

    get "version" do
      api.version
    end

    namespace :public do
      options '/' do
        header('Access-Control-Allow-Headers', '')
        header('Access-Control-Allow-Methods', '')
        ""
      end

      options '/:uuid' do
        header('Access-Control-Allow-Headers', 'origin, x-requested-with, content-type, accept')
        header('Access-Control-Allow-Methods', 'GET,PUT,OPTIONS, POST')
        header('Access-Control-Max-Age', '1728000')
        ""
      end

      get '/:uuid' do
        set = DataSet.where(entity: params[:uuid]).first
        set ? set.payload : {}
      end

      post '/:uuid' do
        set = DataSet.create!(entity: params[:uuid], payload: payload)
        set.payload
      end

      put '/:uuid' do
        set = DataSet.where(entity: params[:uuid]).first
        raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: params[:uuid]) unless set
        set.update_attributes(payload: payload)
        set.payload
      end
    end
  end
end