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

      def own_data?(uuid)
        @token_owner['uuid'] == uuid
      end

      def system_level_privileges?
        @token_owner['type'] == 'app'
      end

      def is_authorized_to_access?(uuid)
        system_level_privileges? || own_data?(uuid)
      end

      def prevent_access!
        error!('Unauthenticated', 403)
      end

      def uuid
        params[:uuid]
      end
    end

    before do
      header('Access-Control-Allow-Origin', request.env['HTTP_ORIGIN'] || '*')

      unless request.env['REQUEST_METHOD'] == 'OPTIONS'
        error!('Unauthenticated', 403) unless request.env['HTTP_AUTHORIZATION']
        token = request.env['HTTP_AUTHORIZATION'].gsub(/^Bearer\s+/, '')
        @token_owner = connection.auth.token_owner(token)
        prevent_access! unless @token_owner
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
      prevent_access! unless system_level_privileges?

      uuids = params[:uuids]
      uuids = JSON.parse(uuids) if uuids.kind_of?(String)

      sets = DataSet.where(entity: {'$in' => uuids})

      Hash[sets.map {|set| [set.entity, response_from_set(set)]}]
    end

    get '/:uuid' do
      prevent_access! unless is_authorized_to_access?(uuid)

      set = DataSet.where(entity: uuid).first
      raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: uuid) unless set
      response_from_set set
    end

    post '/:uuid' do
      prevent_access! unless is_authorized_to_access?(uuid)

      create_set(uuid)
    end

    put '/:uuid' do
      prevent_access! unless is_authorized_to_access?(uuid)

      set = DataSet.where(entity: uuid).first
      raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: uuid) unless set

      set.update_attributes(payload: payload)
      response_from_set set
    end

    put '/:uuid/*key' do
      prevent_access! unless is_authorized_to_access?(uuid)

      set = DataSet.where(entity: uuid).first
      raise Mongoid::Errors::DocumentNotFound.new(DataSet, entity: uuid) unless set

      set.partial_update_attributes(params[:key], payload)
      response_from_set set
    end
  end
end
