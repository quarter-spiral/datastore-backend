require_relative '../spec_helper'

include Datastore::Backend

client = Rack::Client.new {
  use AuthenticationInjector

  run API_APP
}

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

token = AUTH_HELPERS.get_token

app = AUTH_HELPERS.create_app!
app_token = AUTH_HELPERS.get_app_token(app[:id], app[:secret])

describe "Datastore::Backend API" do
  before do
    @entity1 = UUID.new.generate
    @entity2 = UUID.new.generate
    AuthenticationInjector.reset!
  end

  after do
    DataSet.where(entity: @entity1).destroy
    DataSet.where(entity: @entity2).destroy
  end

  describe "data sets" do
    it "can't access the api unauthenticated" do
      client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data)).status.should eq 403

      response = client.get("/v1/#{@entity1}")
      response.status.should eq 403
      JSON.parse(response.body).should eq('error' => 'Unauthenticated')

      client.put("/v1/#{@entity1}", {}, JSON.dump({test: 'yes'})).status.should eq 403
    end

    describe "authenticated" do
      before do
        AuthenticationInjector.token = app_token
      end

      after do
        AuthenticationInjector.reset!
      end

      it "not existing set returns 404" do
        response = client.get("/v1/#{@entity1}")

        response.status.should eq 404
      end

      it "can write data sets" do
        response = client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data))

        response.status.should eq 201
        response_matches(response, @entity1, sample_data).should be true
      end

      it "cannot create data sets without an UUID" do
        response = client.post("/v1/", {}, JSON.dump(sample_data))
        response.status.should eq 405
        response.body.empty?.should be_true
      end

      it "can read data set after writing it" do
        client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data))
        response = client.get("/v1/#{@entity1}")

        response.status.should eq 200
        response_matches(response, @entity1, sample_data).should be true
      end

      it "can retrieve batches of data sets" do
        client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data))

        sample_data_2 = {"bla" => "blub", "yeah" => false}
        client.post("/v1/#{@entity2}", {}, JSON.dump(sample_data_2))

        not_existing_entity = @entity1.reverse
        response = client.get("/v1/batch?uuids=#{CGI.escape(JSON.dump([@entity1, @entity2, not_existing_entity]))}")

        response.status.should eq 200
        JSON.parse(response.body).should eq(
          @entity1 => {"uuid" => @entity1, "data" => sample_data},
          @entity2 => {"uuid" => @entity2, "data" => sample_data_2}
        )
      end

      it "errors out when creating a second data set for the same entity" do
        client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data))
        response = client.post("/v1/#{@entity1}", {}, JSON.dump({}))

        response.status.should eq 403
        JSON.parse(response.body)['error'].should_not be_empty

        response = client.post("/v1/#{@entity2}", {}, JSON.dump({test: 'yes'}))
        response.status.should eq 201

        response = client.get("/v1/#{@entity1}")
        response_matches(response, @entity1, sample_data).should be true

        response = client.get("/v1/#{@entity2}")
        response_matches(response, @entity2, {'test' => 'yes'}).should be true
      end

      it "can change a data set" do
        client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data))
        response = client.put("/v1/#{@entity1}", {}, JSON.dump({test: 'yes'}))

        response.status.should eq 200
        response_matches(response, @entity1, {'test' => 'yes'}).should be true
        response = client.get("/v1/#{@entity1}")
        response_matches(response, @entity1, {'test' => 'yes'}).should be true
      end

      describe "changing only some keys of a data set" do
        before do
          client.post("/v1/#{@entity1}", {}, JSON.dump(sample_data))
        end

        after do
          response_matches(@response, @entity1, @expected_data).should be true
          response = client.get("/v1/#{@entity1}")
          response_matches(response, @entity1, @expected_data).should be true
        end

        it "works with simple values" do
          @response = client.put("/v1/#{@entity1}/integer", {}, JSON.dump({'integer' => 456}))
          @expected_data = sample_data.merge('integer' => 456)
        end

        it "works with whole hashes" do
          @response = client.put("/v1/#{@entity1}/set", {}, JSON.dump({'set' => {'bla' => 'blub'}}))
          @expected_data = sample_data.merge('set' => {'bla' => 'blub'})
        end

        it "works with sub hashes" do
          @response = client.put("/v1/#{@entity1}/set/key", {}, JSON.dump({'key' => 'blub'}))
          @expected_data = sample_data.merge('set' => sample_data['set'].merge('key' => 'blub'))
        end

        it "creats non existing keys in existing hashes" do
          @response = client.put("/v1/#{@entity1}/set/newkey", {}, JSON.dump({'newkey' => 'blub'}))
          @expected_data = sample_data.merge('set' => sample_data['set'].merge('newkey' => 'blub'))
        end

        it "creates whole hashes" do
          @response = client.put("/v1/#{@entity1}/new/some/key", {}, JSON.dump({'key' => 'blub'}))
          @expected_data = sample_data.merge('new' => {'some' => {'key' => 'blub'}})
        end
      end

      it "errors out when changing a non existing data set" do
        response = client.put("/v1/#{@entity1}", {}, JSON.dump({test: 'yes'}))
        response.status.should eq 404
        JSON.parse(response.body).should eq({'error' => 'Not found'})
      end
    end
  end
end
