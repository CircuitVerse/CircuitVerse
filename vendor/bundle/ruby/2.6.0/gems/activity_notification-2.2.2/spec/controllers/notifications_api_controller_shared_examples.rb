require_relative 'controller_spec_utility'

shared_examples_for :notifications_api_controller do
  include ActivityNotification::ControllerSpec::RequestUtility
  include ActivityNotification::ControllerSpec::ApiResponseUtility

  let(:target_params) { { target_type: target_type }.merge(extra_params || {}) }

  describe "GET #index" do
    context "with target_type and target_id parameters" do
      before do
        @notification = create(:notification, target: test_target)
        get_with_compatibility :index, target_params.merge({ target_id: test_target, typed_target_param => 'dummy' }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns JSON response" do
        expect(response_json["count"]).to eq(1)
        assert_json_with_object_array(response_json["notifications"], [@notification])
      end
    end

    context "with target_type and (typed_target)_id parameters" do
      before do
        @notification = create(:notification, target: test_target)
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
    end

    context "without target_type parameters" do
      before do
        @notification = create(:notification, target: test_target)
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
        @notification = create(:notification, target: test_target)
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
      context "with unopened as filter" do
        before do
          @notification = create(:notification, target: test_target)
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'unopened' }), valid_session
        end

        it "returns unopened notification index as JSON" do
          assert_json_with_object_array(response_json["notifications"], [@notification])
        end
      end

      context "with opened as filter" do
        before do
          @notification = create(:notification, target: test_target)
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'opened' }), valid_session
        end

        it "returns unopened notification index as JSON" do
          assert_json_with_object_array(response_json["notifications"], [])
        end
      end
    end

    context "with limit parameter" do
      before do
        create(:notification, target: test_target)
        create(:notification, target: test_target)
      end
      context "with 2 as limit" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, limit: 2 }), valid_session
        end

        it "returns notification index of size 2 as JSON" do
          assert_json_with_array_size(response_json["notifications"], 2)
        end
      end

      context "with 1 as limit" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, limit: 1 }), valid_session
        end

        it "returns notification index of size 1 as JSON" do
          assert_json_with_array_size(response_json["notifications"], 1)
        end
      end
    end

    context "with reverse parameter" do
      before do
        @notifiable    = create(:article)
        @group         = create(:article)
        @key           = 'test.key.1'
        notification   = create(:notification, target: test_target, notifiable: @notifiable)
        create(:notification, target: test_target, notifiable: create(:comment), group: @group, created_at: notification.created_at + 10.second)
        create(:notification, target: test_target, notifiable: create(:article), key: @key, created_at: notification.created_at + 20.second).open!
        @notification1 = test_target.notification_index[0]
        @notification2 = test_target.notification_index[1]
        @notification3 = test_target.notification_index[2]
      end

      context "as default" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
        end

        it "returns the latest order" do
          assert_json_with_object_array(response_json["notifications"], [@notification1, @notification2, @notification3])
        end
      end

      context "with true as reverse" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, reverse: true }), valid_session
        end

        it "returns the earliest order" do
          assert_json_with_object_array(response_json["notifications"], [@notification2, @notification1, @notification3])
        end
      end
    end

    context "with options filter parameters" do
      before do
        @notifiable    = create(:article)
        @group         = create(:article)
        @key           = 'test.key.1'
        @notification2 = create(:notification, target: test_target, notifiable: @notifiable)
        @notification1 = create(:notification, target: test_target, notifiable: create(:comment), group: @group, created_at: @notification2.created_at + 10.second)
        @notification3 = create(:notification, target: test_target, notifiable: create(:article), key: @key, created_at: @notification2.created_at + 20.second)
        @notification3.open!
      end

      context 'with filtered_by_type parameter' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_type: 'Article' }), valid_session
          assert_json_with_object_array(response_json["notifications"], [@notification2, @notification3])
        end
      end

      context 'with filtered_by_group_type and filtered_by_group_id parameters' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_group_type: 'Article', filtered_by_group_id: @group.id.to_s }), valid_session
          assert_json_with_object_array(response_json["notifications"], [@notification1])
        end
      end

      context 'with filtered_by_key parameter' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_key: @key }), valid_session
          assert_json_with_object_array(response_json["notifications"], [@notification3])
        end
      end

      context 'with later_than parameter' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, later_than: (@notification1.created_at.in_time_zone + 0.001).iso8601(3) }), valid_session
          assert_json_with_object_array(response_json["notifications"], [@notification3])
        end
      end

      context 'with earlier_than parameter' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, earlier_than: @notification1.created_at.iso8601(3) }), valid_session
          assert_json_with_object_array(response_json["notifications"], [@notification2])
        end
      end
    end
  end

  describe "POST #open_all" do
    context "http POST request" do
      before do
        @notification = create(:notification, target: test_target)
        expect(@notification.opened?).to be_falsey
        post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "opens all notifications of the target" do
        expect(@notification.reload.opened?).to be_truthy
      end

      it "returns JSON response" do
        expect(response_json["count"]).to eq(1)
        assert_json_with_object_array(response_json["notifications"], [@notification])
      end
    end

    context "with filter request parameters" do
      before do
        @target_1, @notifiable_1, @group_1, @key_1 = create(:confirmed_user), create(:article), nil,           "key.1"
        @target_2, @notifiable_2, @group_2, @key_2 = create(:confirmed_user), create(:comment), @notifiable_1, "key.2"
        @notification_1 = create(:notification, target: test_target, notifiable: @notifiable_1, group: @group_1, key: @key_1)
        @notification_2 = create(:notification, target: test_target, notifiable: @notifiable_2, group: @group_2, key: @key_2, created_at: @notification_1.created_at + 10.second)
        expect(@notification_1.opened?).to be_falsey
        expect(@notification_2.opened?).to be_falsey
      end

      context "with filtered_by_type request parameters" do
        it "opens filtered notifications only" do
          post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target, 'filtered_by_type' => @notifiable_2.to_class_name }), valid_session
          expect(@notification_1.reload.opened?).to be_falsey
          expect(@notification_2.reload.opened?).to be_truthy
        end
      end
  
      context 'with filtered_by_group_type and :filtered_by_group_id request parameters' do
        it "opens filtered notifications only" do
          post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target, 'filtered_by_group_type' => 'Article', 'filtered_by_group_id' => @group_2.id.to_s }), valid_session
          expect(@notification_1.reload.opened?).to be_falsey
          expect(@notification_2.reload.opened?).to be_truthy
        end
      end

      context 'with filtered_by_key request parameters' do
        it "opens filtered notifications only" do
          post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target, 'filtered_by_key' => 'key.2' }), valid_session
          expect(@notification_1.reload.opened?).to be_falsey
          expect(@notification_2.reload.opened?).to be_truthy
        end
      end

      context 'with later_than parameter' do
        it "opens filtered notifications only" do
          post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target, later_than: (@notification_1.created_at.in_time_zone + 0.001).iso8601(3) }), valid_session
          expect(@notification_1.reload.opened?).to be_falsey
          expect(@notification_2.reload.opened?).to be_truthy
        end
      end

      context 'with earlier_than parameter' do
        it "opens filtered notifications only" do
          post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target, earlier_than: @notification_2.created_at.iso8601(3) }), valid_session
          expect(@notification_1.reload.opened?).to be_truthy
          expect(@notification_2.reload.opened?).to be_falsey
        end
      end

      context "with no filter request parameters" do
        it "opens all notifications of the target" do
          post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target}), valid_session
          expect(@notification_1.reload.opened?).to be_truthy
          expect(@notification_2.reload.opened?).to be_truthy
        end
      end
    end
  end

  describe "GET #show" do
    context "with id, target_type and (typed_target)_id parameters" do
      before do
        @notification = create(:notification, target: test_target)
        get_with_compatibility :show, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns the requested notification as JSON" do
        assert_json_with_object(response_json, @notification)
      end
    end

    context "with wrong id and (typed_target)_id parameters" do
      before do
        @notification = create(:notification, target: create(:user))
        get_with_compatibility :show, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 403 as http status code" do
        expect(response.status).to eq(403)
      end

      it "returns error JSON response" do
        assert_error_response(403)
      end
    end

    context "when associated notifiable record was not found" do
      before do
        @notification = create(:notification, target: test_target)
        @notification.notifiable.delete
        get_with_compatibility :show, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 500 as http status code" do
        expect(response.status).to eq(500)
      end

      it "returns error JSON response" do
        assert_error_response(500)
      end
    end
  end

  describe "DELETE #destroy" do
    context "http DELETE request" do
      before do
        @notification = create(:notification, target: test_target)
        delete_with_compatibility :destroy, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 204 as http status code" do
        expect(response.status).to eq(204)
      end

      it "deletes the notification" do
        expect(test_target.notifications.where(id: @notification.id).exists?).to be_falsey
      end
    end
  end

  describe "PUT #open" do
    context "without move parameter" do
      context "http PUT request" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          put_with_compatibility :open, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
        end

        it "returns 200 as http status code" do
          expect(response.status).to eq(200)
        end

        it "opens the notification" do
          expect(@notification.reload.opened?).to be_truthy
        end

        it "returns JSON response" do
          expect(response_json["count"]).to eq(1)
          assert_json_with_object(response_json["notification"], @notification)
        end
      end
    end

    context "with true as move parameter" do
      context "http PUT request" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          put_with_compatibility :open, target_params.merge({ id: @notification, typed_target_param => test_target, move: true }), valid_session
        end

        it "returns 302 as http status code" do
          expect(response.status).to eq(302)
        end

        it "opens the notification" do
          expect(@notification.reload.opened?).to be_truthy
        end

        it "redirects to notifiable_path" do
          expect(response).to redirect_to @notification.notifiable_path
        end
      end
    end
  end

  describe "GET #move" do
    context "without open parameter" do
      context "http GET request" do
        before do
          @notification = create(:notification, target: test_target)
          get_with_compatibility :move, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
        end

        it "returns 302 as http status code" do
          expect(response.status).to eq(302)
        end

        it "redirects to notifiable_path" do
          expect(response).to redirect_to @notification.notifiable_path
        end
      end
    end

    context "with true as open parameter" do
      context "http GET request" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          get_with_compatibility :move, target_params.merge({ id: @notification, typed_target_param => test_target, open: true }), valid_session
        end

        it "returns 302 as http status code" do
          expect(response.status).to eq(302)
        end

        it "opens the notification" do
          expect(@notification.reload.opened?).to be_truthy
        end

        it "redirects to notifiable_path" do
          expect(response).to redirect_to @notification.notifiable_path
        end
      end
    end
  end
end

shared_examples_for :notifications_api_request do
  include ActivityNotification::ControllerSpec::CommitteeUtility

  before do
    group = create(:article)
    notifier = create(:user)
    create(:notification, target: test_target)
    group_owner = create(:notification, target: test_target, group: group, notifier: notifier, parameters: { "test_default_param": "1" })
    @notification = create(:notification, target: test_target, group: group, group_owner: group_owner, notifier: notifier, parameters: { "test_default_param": "1" })
    group_owner.open!
  end

  describe "GET /apidocs" do
    it "returns API references as OpenAPI Specification JSON schema" do
      get "#{root_path}/apidocs"
      write_schema_file(response.body)
      expect(read_schema_file["openapi"]).to eq("3.0.0")
    end
  end

  describe "GET /{target_type}/{target_id}/notifications", type: :request do
    it "returns response as API references" do
      get_with_compatibility "#{api_path}/notifications", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "POST /{target_type}/{target_id}/notifications/open_all", type: :request do
    it "returns response as API references" do
      post_with_compatibility "#{api_path}/notifications/open_all", headers: @headers
      assert_all_schema_confirm(response, 200)
    end
  end

  describe "GET /{target_type}/{target_id}/notifications/{id}", type: :request do
    it "returns response as API references" do
      get_with_compatibility "#{api_path}/notifications/#{@notification.id}", headers: @headers
      assert_all_schema_confirm(response, 200)
    end

    it "returns error response as API references" do
      get_with_compatibility "#{api_path}/notifications/0", headers: @headers
      assert_all_schema_confirm(response, 404)
    end
  end

  describe "DELETE /{target_type}/{target_id}/notifications/{id}", type: :request do
    it "returns response as API references" do
      delete_with_compatibility "#{api_path}/notifications/#{@notification.id}", headers: @headers
      assert_all_schema_confirm(response, 204)
    end
  end

  describe "PUT /{target_type}/{target_id}/notifications/{id}/open", type: :request do
    it "returns response as API references" do
      put_with_compatibility "#{api_path}/notifications/#{@notification.id}/open", headers: @headers
      assert_all_schema_confirm(response, 200)
    end

    it "returns response as API references when request parameters have move=true" do
      put_with_compatibility "#{api_path}/notifications/#{@notification.id}/open?move=true", headers: @headers
      assert_all_schema_confirm(response, 302)
    end
  end

  describe "GET /{target_type}/{target_id}/notifications/{id}/move", type: :request do
    it "returns response as API references" do
      get_with_compatibility "#{api_path}/notifications/#{@notification.id}/move", headers: @headers
      assert_all_schema_confirm(response, 302)
    end
  end
end
