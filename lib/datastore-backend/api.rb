require 'grape'
require 'uuid'

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

      def response_from_set(set)
        {uuid: set.entity, data: set.payload}
      end

      def create_set(uuid)
        set = DataSet.create!(entity: uuid, payload: payload)
        response_from_set set
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
        raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: params[:uuid]) unless set

        response_from_set set
      end

      post '/' do
        create_set(UUID.new.generate)
      end

      post '/:uuid' do
        create_set(params[:uuid])
      end

      put '/:uuid' do
        set = DataSet.where(entity: params[:uuid]).first
        raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: params[:uuid]) unless set

        set.update_attributes(payload: payload)
        response_from_set set
      end

      put '/:uuid/*key' do
        set = DataSet.where(entity: params[:uuid]).first
        raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: params[:uuid]) unless set

        set.partial_update_attributes(params[:key], payload)
        response_from_set set
      end
    end
  end
end
