require 'auth-client'
require 'grape'
require 'grape_newrelic'
require 'uuid'

module Datastore::Backend
  class API < ::Grape::API
    use GrapeNewrelic::Instrumenter
    version 'v1', :using => :path, :vendor => 'qs'

    format :json
    default_format :json

    rescue_from Mongoid::Errors::Validations
    rescue_from Mongoid::Errors::DocumentNotFound do
      Rack::Response.new([ JSON.dump({error: 'Not found'}) ], 404, { "Content-type" => "application/json" }).finish
    end
    default_error_formatter :json

    helpers do
      def payload
        return @payload if @payload

        body = request.body
        body =body.read if body.respond_to?(:read)

        @payload = JSON.parse(body)
      end

      def response_from_set(set)
        {uuid: set.entity, data: set.payload}
      end

      def create_set(uuid)
        set = DataSet.create!(entity: uuid, payload: payload)
        response_from_set set
      end

      def connection
        @connection ||= Connection.create
      end
    end

    before do
      header('Access-Control-Allow-Origin', request.env['HTTP_ORIGIN'] || '*')

      unless request.env['REQUEST_METHOD'] == 'OPTIONS'
        error!('Unauthenticated', 403) unless request.env['HTTP_AUTHORIZATION']
        token = request.env['HTTP_AUTHORIZATION'].gsub(/^Bearer\s+/, '')
        error!('Unauthenticated', 403) unless connection.auth.token_valid?(token)
      end
    end

    get "version" do
      api.version
    end

    options '/' do
      header('Access-Control-Allow-Headers', '')
      header('Access-Control-Allow-Methods', '')
      ""
    end

    options '/:uuid' do
      header('Access-Control-Allow-Headers', 'origin, x-requested-with, content-type, accept, authorization')
      header('Access-Control-Allow-Methods', 'GET,PUT,OPTIONS, POST')
      header('Access-Control-Max-Age', '1728000')
      ""
    end

    get '/batch' do
      uuids = params[:uuids] || []
      uuids = JSON.parse(uuids) if uuids.kind_of?(String)

      sets = DataSet.where(entity: {'$in' => uuids})

      Hash[sets.map {|set| [set.entity, response_from_set(set)]}]
    end

    get '/:uuid' do
      set = DataSet.where(entity: params[:uuid]).first
      raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: params[:uuid]) unless set
      response_from_set set
    end

    post '/:uuid' do
      create_set(params[:uuid])
    end

    post '/' do
      create_set(UUID.new.generate)
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
