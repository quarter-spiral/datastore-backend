module Datastore::Backend
  class DataSet
    include Mongoid::Document

    field :entity,  type: String
    field :payload, type: Hash

    index({entity: 1}, unique: true)
  end
end