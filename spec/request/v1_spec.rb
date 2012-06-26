require 'spec_helper'
require 'json'
require 'uuid'

include Datastore::Backend

client = Rack::Client.new {run API}

describe "Datastore::Backend API" do
  before do
    @entity1 = UUID.new.generate
  end

  describe "public data sets" do
    it "can read data sets" do
      response = client.get("/v1/public/#{@entity1}")
      response.status.should be 200

      JSON.parse(response.body).should eq({})
    end
  end
end