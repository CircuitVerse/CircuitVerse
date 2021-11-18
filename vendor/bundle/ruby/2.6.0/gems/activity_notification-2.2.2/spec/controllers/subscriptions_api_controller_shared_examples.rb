require_relative 'controller_spec_utility'

shared_examples_for :subscriptions_api_controller do
  include ActivityNotification::ControllerSpec::RequestUtility
  include ActivityNotification::ControllerSpec::ApiResponseUtility

  let(:target_params) { { target_type: target_type }.merge(extra_params || {}) }

  describe "GET #index" do
    context "with target_type and target_id parameters" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @notification = create(:notification, target: test_target, key: 'test_notification_key')
        get_with_compatibility :index, target_params.merge({ target_id: test_target, typed_target_param => 'dummy' }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns configured subscription index as JSON" do
        expect(response_json["configured_count"]).to eq(1)
        assert_json_with_object_array(response_json["subscriptions"], [@subscription])
      end

      it "returns unconfigured notification keys as JSON" do
        expect(response_json["unconfigured_count"]).to eq(1)
        expect(response_json['unconfigured_notification_keys']).to eq([@notification.key])
      end
    end

    context "with target_type and (typed_target)_id parameters" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @notification = create(:notification, target: test_target, key: 'test_notification_key')
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns subscription index as JSON" do
        expect(response_json["configured_count"]).to eq(1)
        assert_json_with_object_array(response_json["subscriptions"], [@subscription])
      end

      it "returns unconfigured notification keys as JSON" do
        expect(response_json["unconfigured_count"]).to eq(1)
        expect(response_json['unconfigured_notification_keys']).to eq([@notification.key])
      end
    end

    context "without target_type parameters" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @notification = create(:notification, target: test_target, key: 'test_notification_key')
        get_with_compatibility :index, { typed_target_param => test_target }, valid_session
      end

      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end

      it "returns error JSON response" do
        assert_error_response(400)
      end
    end

    context "with not found (typed_target)_id parameter" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @notification = create(:notification, target: test_target, key: 'test_notification_key')
        get_with_compatibility :index, target_params.merge({ typed_target_param => 0 }), valid_session
      end

      it "returns 404 as http status code" do
        expect(response.status).to eq(404)
      end

      it "returns error JSON response" do
        assert_error_response(404)
      end
    end

    context "with filter parameter" do
      context "with configured as filter" do
        before do
          @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
          @notification = create(:notification, target: test_target, key: 'test_notification_key')
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'configured' }), valid_session
        end

        it "returns configured subscription index as JSON" do
          expect(response_json["configured_count"]).to eq(1)
          assert_json_with_object_array(response_json["subscriptions"], [@subscription])
        end

        it "does not return unconfigured notification keys as JSON" do
          expect(response_json['unconfigured_count']).to be_nil
          expect(response_json['unconfigured_notification_keys']).to be_nil
        end
      end

      context "with unconfigured as filter" do
        before do
          @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
          @notification = create(:notification, target: test_target, key: 'test_notification_key')
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'unconfigured' }), valid_session
        end

        it "does not return configured subscription index as JSON" do
          expect(response_json['configured_count']).to be_nil
          expect(response_json['subscriptions']).to be_nil
        end

        it "returns unconfigured notification keys as JSON" do
          expect(response_json["unconfigured_count"]).to eq(1)
          expect(response_json['unconfigured_notification_keys']).to eq([@notification.key])
        end
      end
    end

    context "with limit parameter" do
      before do
        create(:subscription, target: test_target, key: 'test_subscription_key_1')
        create(:subscription, target: test_target, key: 'test_subscription_key_2')
        create(:notification, target: test_target, key: 'test_notification_key_1')
        create(:notification, target: test_target, key: 'test_notification_key_2')
      end
      context "with 2 as limit" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, limit: 2 }), valid_session
        end

        it "returns subscription index of size 2 as JSON" do
          assert_json_with_array_size(response_json["subscriptions"], 2)
        end

        it "returns notification key index of size 2 as JSON" do
          assert_json_with_array_size(response_json["unconfigured_notification_keys"], 2)
        end
      end

      context "with 1 as limit" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, limit: 1 }), valid_session
        end

        it "returns subscription index of size 1 as JSON" do
          assert_json_with_array_size(response_json["subscriptions"], 1)
        end

        it "returns notification key index of size 1 as JSON" do
          assert_json_with_array_size(response_json["unconfigured_notification_keys"], 1)
        end
      end
    end

    context "with options filter parameters" do
      before do
        @subscription1 = create(:subscription, target: test_target, key: 'test_subscription_key_1')
        @subscription2 = create(:subscription, target: test_target, key: 'test_subscription_key_2')
        @notification1 = create(:notification, target: test_target, key: 'test_notification_key_1')
        @notification2 = create(:notification, target: test_target, key: 'test_notification_key_2')
      end

      context 'with filtered_by_key parameter' do
        it "returns filtered subscriptions only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_key: 'test_subscription_key_2' }), valid_session
          assert_json_with_object_array(response_json["subscriptions"], [@subscription2])
        end

        it "returns filtered notification keys only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_key: 'test_notification_key_2' }), valid_session
          expect(response_json['unconfigured_notification_keys']).to eq([@notification2.key])
        end
      end
    end
  end

  describe "POST #create" do
    before do
      expect(test_target.subscriptions.size).to eq(0)
    end

    context "http POST request without optional targets" do
      before do
        post_with_compatibility :create, target_params.merge({
            typed_target_param => test_target,
            "subscription"     => { "key"        => "new_subscription_key",
                                    "subscribing"=> "true",
                                    "subscribing_to_email"=>"true"
                                  }
          }), valid_session
      end

      it "returns 201 as http status code" do
        expect(response.status).to eq(201)
      end

      it "creates new subscription of the target" do
        expect(test_target.subscriptions.reload.size).to      eq(1)
        expect(test_target.subscriptions.reload.first.key).to eq("new_subscription_key")
      end

      it "returns created subscription" do
        created_subscription = test_target.subscriptions.reload.first
        assert_json_with_object(response_json, created_subscription)
      end
    end

    context "http POST request with optional targets" do
      before do
        post_with_compatibility :create, target_params.merge({
            typed_target_param => test_target,
            "subscription"     => { "key"        => "new_subscription_key",
                                    "subscribing"=> "true",
                                    "subscribing_to_email"=>"true",
                                    "optional_targets" => { "subscribing_to_base1" => "true", "subscribing_to_base2" => "false" }
                                  }
          }), valid_session
      end

      it "returns 201 as http status code" do
        expect(response.status).to eq(201)
      end

      it "creates new subscription of the target" do
        expect(test_target.subscriptions.reload.size).to eq(1)
        created_subscription = test_target.subscriptions.reload.first
        expect(created_subscription.key).to eq("new_subscription_key")
        expect(created_subscription.subscribing_to_optional_target?("base1")).to be_truthy
        expect(created_subscription.subscribing_to_optional_target?("base2")).to be_falsey
      end

      it "returns created subscription" do
        created_subscription = test_target.subscriptions.reload.first
        assert_json_with_object(response_json, created_subscription)
      end
    end

    context "without subscription parameter" do
      before do
        put_with_compatibility :create, target_params.merge({
            typed_target_param => test_target
          }), valid_session
      end

      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end

      it "returns error JSON response" do
        assert_error_response(400)
      end
    end

    context "unprocessable entity because of duplicate key" do
      before do
        @duplicate_subscription = create(:subscription, target: test_target, key: 'duplicate_subscription_key')
        put_with_compatibility :create, target_params.merge({
            typed_target_param => test_target,
            "subscription"     => { "key"        => "duplicate_subscription_key",
                                    "subscribing"=> "true",
                                    "subscribing_to_email"=>"true"
                                  }
          }), valid_session
      end

      it "returns 422 as http status code" do
        expect(response.status).to eq(422)
      end

      it "returns error JSON response" do
        assert_error_response(422)
      end
    end
  end

  describe "GET #find" do
    context "with key, target_type and (typed_target)_id parameters" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        get_with_compatibility :find, target_params.merge({ key: 'test_subscription_key', typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns the requested subscription as JSON" do
        assert_json_with_object(response_json, @subscription)
      end
    end

    context "with wrong id and (typed_target)_id parameters" do
      before do
        @subscription = create(:subscription, target: create(:user))
        get_with_compatibility :find, target_params.merge({ key: 'test_subscription_key', typed_target_param => test_target }), valid_session
      end

      it "returns 404 as http status code" do
        expect(response.status).to eq(404)
      end

      it "returns error JSON response" do
        assert_error_response(404)
      end
    end
  end

  describe "GET #optional_target_names" do
    context "with key, target_type and (typed_target)_id parameters" do
      before do
        @notification = create(:notification, target: test_target, key: 'test_subscription_key')
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        get_with_compatibility :optional_target_names, target_params.merge({ key: 'test_subscription_key', typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns the blank array since configurured optional targets are not configured" do
        expect(JSON.parse(response.body)["optional_target_names"].is_a?(Array)).to be_truthy
      end
    end

    context "with wrong id and (typed_target)_id parameters" do
      before do
        @subscription = create(:subscription, target: create(:user))
        get_with_compatibility :find, target_params.merge({ key: 'test_subscription_key', typed_target_param => test_target }), valid_session
      end

      it "returns 404 as http status code" do
        expect(response.status).to eq(404)
      end

      it "returns error JSON response" do
        assert_error_response(404)
      end
    end
  end

  describe "GET #show" do
    context "with id, target_type and (typed_target)_id parameters" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        get_with_compatibility :show, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns the requested subscription as JSON" do
        assert_json_with_object(response_json, @subscription)
      end
    end

    context "with wrong id and (typed_target)_id parameters" do
      before do
        @subscription = create(:subscription, target: create(:user))
        get_with_compatibility :show, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 403 as http status code" do
        expect(response.status).to eq(403)
      end

      it "returns error JSON response" do
        assert_error_response(403)
      end
    end
  end

  describe "DELETE #destroy" do
    context "http DELETE request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        delete_with_compatibility :destroy, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 204 as http status code" do
        expect(response.status).to eq(204)
      end

      it "deletes the subscription" do
        expect(test_target.subscriptions.where(id: @subscription.id).exists?).to be_falsey
      end
    end
  end

  describe "PUT #subscribe" do
    context "http PUT request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        put_with_compatibility :subscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "updates subscribing to true" do
        expect(@subscription.reload.subscribing?).to be_truthy
      end

      it "returns JSON response" do
        assert_json_with_object(response_json, @subscription)
      end
    end
  end

  describe "PUT #unsubscribe" do
    context "http PUT request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing?).to be_truthy
        put_with_compatibility :unsubscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "updates subscribing to false" do
        expect(@subscription.reload.subscribing?).to be_falsey
      end

      it "returns JSON response" do
        assert_json_with_object(response_json, @subscription)
      end
    end
  end

  describe "PUT #subscribe_to_email" do
    context "http PUT request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_email
        expect(@subscription.subscribing_to_email?).to be_falsey
        put_with_compatibility :subscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "updates subscribing_to_email to true" do
        expect(@subscription.reload.subscribing_to_email?).to be_truthy
      end

      it "returns JSON response" do
        assert_json_with_object(response_json, @subscription)
      end
    end

    context "with unsubscribed target" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        expect(@subscription.subscribing_to_email?).to be_falsey
        put_with_compatibility :subscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 422 as http status code" do
        expect(response.status).to eq(422)
      end

      it "cannot update subscribing_to_email to true" do
        expect(@subscription.reload.subscribing_to_email?).to be_falsey
      end

      it "returns error JSON response" do
        assert_error_response(422)
      end
    end
  end

  describe "PUT #unsubscribe_to_email" do
    context "http PUT request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_email?).to be_truthy
        put_with_compatibility :unsubscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "updates subscribing_to_email to false" do
        expect(@subscription.reload.subscribing_to_email?).to be_falsey
      end

      it "returns JSON response" do
        assert_json_with_object(response_json, @subscription)
      end
    end
  end

  describe "PUT #subscribe_to_optional_target" do
    context "without optional_target_name param" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        put_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end

      it "does not update subscribing_to_optional_target?" do
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "returns error JSON response" do
        assert_error_response(400)
      end
    end

    context "http PUT request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        put_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "updates subscribing_to_optional_target to true" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_truthy
      end

      it "returns JSON response" do
        assert_json_with_object(response_json, @subscription)
      end
    end

    context "with unsubscribed target" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        put_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 422 as http status code" do
        expect(response.status).to eq(422)
      end

      it "cannot update subscribing_to_optional_target to true" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "returns error JSON response" do
        assert_error_response(422)
      end
    end
  end

  describe "PUT #unsubscribe_to_optional_target" do
    context "without optional_target_name param" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
        put_with_compatibility :unsubscribe_to_optional_target, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end

      it "does not update subscribing_to_optional_target?" do
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
      end

      it "returns error JSON response" do
        assert_error_response(400)
      end
    end

    context "http PUT request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
        put_with_compatibility :unsubscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "updates subscribing_to_optional_target to false" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "returns JSON response" do
        assert_json_with_object(response_json, @subscription)
      end
    end
  end
end

shared_examples_for :subscriptions_api_request do
  include ActivityNotification::ControllerSpec::CommitteeUtility

  before do
    @notification = create(:notification, target: test_target, key: "unconfigured_key")
    @subscription = create(:subscription, target: test_target, key: "configured_key")
  end

  describe "GET /apidocs to test" do
    it "returns API references as OpenAPI Specification JSON schema" do
      get "#{root_path}/apidocs"
      write_schema_file(response.body)
      expect(read_schema_file["openapi"]).to eq("3.0.0")
    end
  end

  describe "GET /{target_type}/{target_id}/subscriptions", type: :request do
    it "returns response as API references" do
      get_with_compatibility "#{api_path}/subscriptions", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "POST /{target_type}/{target_id}/subscriptions", type: :request do
    it "returns response as API references" do
      post_with_compatibility "#{api_path}/subscriptions", params: {
        "subscription"  => { "key"        => "new_subscription_key",
                             "subscribing"=> "true",
                             "subscribing_to_email"=>"true",
                             "optional_targets"=>{
                               "action_cable_channel"=>{
                                 "subscribing"=>"true",
                               },
                               "slack"=>{
                                 "subscribing"=>"false"
                               }
                             }
                           }
      }, headers: @headers
      assert_all_schema_confirm(response, 201)
    end

    it "returns response as API references when the key is duplicate" do
      post_with_compatibility "#{api_path}/subscriptions", params: {
        "subscription"  => { "key"        => "configured_key",
                             "subscribing"=> "true",
                             "subscribing_to_email"=>"true"
                           }
      }, headers: @headers
      assert_all_schema_confirm(response, 422)
    end
  end

  describe "GET /{target_type}/{target_id}/subscriptions/find", type: :request do
    it "returns response as API references" do
      get_with_compatibility "#{api_path}/subscriptions/find?key=#{@subscription.key}", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "GET /{target_type}/{target_id}/subscriptions/optional_target_names", type: :request do
    it "returns response as API references" do
      create(:notification, target: test_target, key: @subscription.key)
      get_with_compatibility "#{api_path}/subscriptions/optional_target_names?key=#{@subscription.key}", headers: @headers
      assert_all_schema_confirm(response, 200)
    end

    it "returns response as API references when any notification with the key is not found" do
      get_with_compatibility "#{api_path}/subscriptions/optional_target_names?key=#{@subscription.key}", headers: @headers
      assert_all_schema_confirm(response, 404)
    end
  end

  describe "GET /{target_type}/{target_id}/subscriptions/{id}", type: :request do
    it "returns response as API references" do
      get_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}", headers: @headers
      assert_all_schema_confirm(response, 200)
    end

    it "returns error response as API references" do
      get_with_compatibility "#{api_path}/subscriptions/0", headers: @headers
      assert_all_schema_confirm(response, 404)
    end
  end

  describe "DELETE /{target_type}/{target_id}/subscriptions/{id}", type: :request do
    it "returns response as API references" do
      delete_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}", headers: @headers
      assert_all_schema_confirm(response, 204)
    end
  end

  describe "PUT /{target_type}/{target_id}/subscriptions/{id}/subscribe", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}/subscribe", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "PUT /{target_type}/{target_id}/subscriptions/{id}/unsubscribe", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}/unsubscribe", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "PUT /{target_type}/{target_id}/subscriptions/{id}/subscribe_to_email", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}/subscribe_to_email", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "PUT /{target_type}/{target_id}/subscriptions/{id}/unsubscribe_to_email", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}/unsubscribe_to_email", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "PUT /{target_type}/{target_id}/subscriptions/{id}/subscribe_to_optional_target", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}/subscribe_to_optional_target?optional_target_name=slack", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "PUT /{target_type}/{target_id}/subscriptions/{id}/unsubscribe_to_optional_target", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/subscriptions/#{@subscription.id}/unsubscribe_to_optional_target?optional_target_name=slack", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end
end
