require 'mongoid'

module Datastore::Backend
  class DataSet
    include Mongoid::Document

    field :entity,  type: String
    field :payload, type: Hash

    validates :entity, uniqueness: true

    index({entity: 1}, unique: true)

    def partial_update_attributes(key, payload)
      new_data = {}

      if self[key]
        data = payload[key]
        new_data = {key => data}
      else
        keys = key.split('/')
        data = payload[keys.last]

        current_sets_raw_payload = Hash[self.payload.to_a]
        new_data = deep_hash(keys, current_sets_raw_payload, data)
      end

      update_attributes(payload: new_data)
    end

    protected
    def deep_hash(keys, hash, data)
      key = keys.shift
      hash[key] = {} unless hash[key]
      if keys.empty?
        hash[key] = data
      else
        deep_hash(keys, hash[key], data)
      end

      hash
    end
  end
end
