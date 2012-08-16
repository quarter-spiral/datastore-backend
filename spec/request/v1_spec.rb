require 'spec_helper'
require 'json'
require 'uuid'

include Datastore::Backend

client = Rack::Client.new {run API}

sample_data = {
  'null' => nil,
  'boolean_true' => true,
  'boolean_false' => false,
  'integer' => 123,
  'float' => 123.456,
  'string' => 'some cool string',
  'array' => [123, 'Hallo', [1,2,3], false],
  'set' => {'key' => 'value', 'second' => 'value2', 'third' => [7, 'yip', {'inner'  => 'hash'}]}
}

describe "Datastore::Backend API" do
  before do
    @entity1 = UUID.new.generate
    @entity2 = UUID.new.generate
  end

  after do
    DataSet.where(entity: @entity1).destroy
    DataSet.where(entity: @entity2).destroy
  end

  describe "public data sets" do
    it "not existing set returns 404" do
      response = client.get("/v1/public/#{@entity1}")

      response.status.should eq 404
    end

    it "can write data sets" do
      response = client.post("/v1/public/#{@entity1}", {}, JSON.dump(sample_data))

      response.status.should eq 201
      response_matches(response, sample_data).should be true
    end

    it "can read data set after writing it" do
      client.post("/v1/public/#{@entity1}", {}, JSON.dump(sample_data))
      response = client.get("/v1/public/#{@entity1}")

      response.status.should eq 200
      response_matches(response, sample_data).should be true
    end

    it "errors out when creating a second data set for the same entity" do
      client.post("/v1/public/#{@entity1}", {}, JSON.dump(sample_data))
      response = client.post("/v1/public/#{@entity1}", {}, JSON.dump({}))

      response.status.should eq 403
      JSON.parse(response.body)['error'].should_not be_empty

      response = client.post("/v1/public/#{@entity2}", {}, JSON.dump({test: 'yes'}))
      response.status.should eq 201

      response = client.get("/v1/public/#{@entity1}")
      response_matches(response, sample_data).should be true

      response = client.get("/v1/public/#{@entity2}")
      response_matches(response, {'test' => 'yes'}).should be true
    end

    it "can change an entry" do
      client.post("/v1/public/#{@entity1}", {}, JSON.dump(sample_data))
      response = client.put("/v1/public/#{@entity1}", {}, JSON.dump({test: 'yes'}))

      response.status.should eq 200
      response_matches(response, {'test' => 'yes'}).should be true
      response = client.get("/v1/public/#{@entity1}")
      response_matches(response, {'test' => 'yes'}).should be true
    end

    it "errors out when changing a non existing data set" do
      response = client.put("/v1/public/#{@entity1}", {}, JSON.dump({test: 'yes'}))
      response.status.should eq 404
      JSON.parse(response.body).should eq({'error' => 'Not found'})
    end
  end
end
