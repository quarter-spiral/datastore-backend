require 'spec_helper'

include Datastore::Backend

client = Rack::Client.new {run Api}

describe "Datastore::Backend API" do
  before do
    @entity1 = UUID.new.generate
  end

  describe "public data sets" do
    it "can read data sets" do
      client.get('/v1/public/')
    end
  end
end