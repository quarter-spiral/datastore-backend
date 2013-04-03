require_relative '../spec_helper'
require 'json'
require 'uuid'

include Datastore::Backend

require_relative '../spec_helper'

include Datastore::Backend

client = Rack::Client.new {
  use AuthenticationInjector

  run API_APP
}

user = AUTH_HELPERS.user_data['uuid']
token = AUTH_HELPERS.get_token

app = AUTH_HELPERS.create_app!
app_token = AUTH_HELPERS.get_app_token(app[:id], app[:secret])

describe "Authorization of the API" do
  describe "for users" do
    before do
      AuthenticationInjector.token = token
    end

    after do
      AuthenticationInjector.reset!
    end

    describe "with own data" do
      before do
        @set = {"test" => 'set'}
        DataSet.create!(entity: user, payload: @set)
      end

      after do
        DataSet.where(entity: user).destroy
      end

      it "allows reads" do
        response = client.get("/v1/#{user}")
        JSON.parse(response.body)['data'].should eq @set
      end

      it "allows creation" do
        DataSet.where(entity: user).destroy
        new_set = {"new" => "setto"}
        response = client.post("/v1/#{user}", {}, JSON.dump(new_set))
        JSON.parse(response.body)['data'].should eq new_set

        response = client.get("/v1/#{user}")
        JSON.parse(response.body)['data'].should eq new_set
      end

      it "allows updates" do
        new_set = {"new" => "setto"}
        response = client.put("/v1/#{user}", {}, JSON.dump(new_set))
        JSON.parse(response.body)['data'].should eq new_set

        response = client.get("/v1/#{user}")
        JSON.parse(response.body)['data'].should eq new_set
      end

      it "prevents batch requests" do
        response = client.get("/v1/batch?uuids[]=#{user}", {})
        response.status.should eq 403
        JSON.parse(response.body)['data'].should_not eq @set
      end
    end

    describe "with other data" do
      before do
        @entity = UUID.new.generate
        @set = {"test" => 'set'}
        DataSet.create!(entity: @entity, payload: @set)
      end

      after do
        DataSet.where(entity: @entity).destroy
      end

      it "prevents reads" do
        response = client.get("/v1/#{@entity}")
        response.status.should eq 403
        JSON.parse(response.body)['data'].should_not eq @set
      end

      it "prevents creation" do
        DataSet.where(entity: @entity).destroy
        new_set = {"new" => "setto"}
        response = client.post("/v1/#{@entity}", {}, JSON.dump(new_set))
        response.status.should eq 403
        JSON.parse(response.body)['data'].should_not eq new_set

        response = client.get("/v1/#{@entity}")
        response.status.should eq 403
        JSON.parse(response.body)['data'].should_not eq new_set
      end

      it "prevents updates" do
        new_set = {"new" => "setto"}
        response = client.put("/v1/#{@entity}", {}, JSON.dump(new_set))
        response.status.should eq 403
        JSON.parse(response.body)['data'].should_not eq new_set

        response = client.get("/v1/#{@entity}")
        response.status.should eq 403
        JSON.parse(response.body)['data'].should_not eq new_set
      end
    end
  end

  describe "for a client with system privileges" do
    describe "with any data" do
      before do
        AuthenticationInjector.token = app_token
        @entity = UUID.new.generate
        @set = {"test" => 'set'}
        DataSet.create!(entity: @entity, payload: @set)
      end

      after do
        DataSet.where(entity: @entity).destroy
      end

      it "allows reads" do
        response = client.get("/v1/#{@entity}")
        JSON.parse(response.body)['data'].should eq @set
      end

      it "allows creation" do
        DataSet.where(entity: @entity).destroy
        new_set = {"new" => "setto"}
        response = client.post("/v1/#{@entity}", {}, JSON.dump(new_set))
        JSON.parse(response.body)['data'].should eq new_set

        response = client.get("/v1/#{@entity}")
        JSON.parse(response.body)['data'].should eq new_set
      end

      it "allows updates" do
        new_set = {"new" => "setto"}
        response = client.put("/v1/#{@entity}", {}, JSON.dump(new_set))
        JSON.parse(response.body)['data'].should eq new_set

        response = client.get("/v1/#{@entity}")
        JSON.parse(response.body)['data'].should eq new_set
      end

      it "allows batch requests" do
        entity2 = UUID.new.generate
        set2 = {"new" => "setto"}
        DataSet.create!(entity: entity2, payload: set2)

        response = client.get("/v1/batch?uuids[]=#{@entity}&uuids[]=#{entity2}", {})
        response.status.should eq 200
        JSON.parse(response.body).should eq(@entity => {"uuid" => @entity, "data" => @set}, entity2 => {"uuid" => entity2, "data" => set2})

        DataSet.where(entity: entity2).destroy
      end
    end
  end
end
