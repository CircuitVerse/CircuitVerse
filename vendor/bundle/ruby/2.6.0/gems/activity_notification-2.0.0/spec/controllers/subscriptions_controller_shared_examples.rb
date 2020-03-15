shared_examples_for :subscription_controller do
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

      it "assigns configured subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "assigns unconfigured notification keys as @notification_keys" do
        expect(assigns(:notification_keys)).to eq([@notification.key])
      end

      it "renders the :index template" do
        expect(response).to render_template :index
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

      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "assigns unconfigured notification keys as @notification_keys" do
        expect(assigns(:notification_keys)).to eq([@notification.key])
      end

      it "renders the :index template" do
        expect(response).to render_template :index
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
    end

    context "with not found (typed_target)_id parameter" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @notification = create(:notification, target: test_target, key: 'test_notification_key')
      end

      it "raises ActiveRecord::RecordNotFound" do
        if ENV['AN_TEST_DB'] == 'mongodb'
          expect {
            get_with_compatibility :index, target_params.merge({ typed_target_param => 0 }), valid_session
          }.to raise_error(Mongoid::Errors::DocumentNotFound)
        else
          expect {
            get_with_compatibility :index, target_params.merge({ typed_target_param => 0 }), valid_session
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "with json as format parameter" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @notification = create(:notification, target: test_target, key: 'test_notification_key')
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, format: :json }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns json format" do
        case ActivityNotification.config.orm
        when :active_record
          expect(JSON.parse(response.body)["subscriptions"].first)
          .to include("target_id" => test_target.id, "target_type" => test_target.to_class_name)
        when :mongoid
          expect(JSON.parse(response.body)["subscriptions"].first)
          .to include("target_id" => test_target.id.to_s, "target_type" => test_target.to_class_name)
        when :dynamoid
          expect(JSON.parse(response.body)["subscriptions"].first)
          .to include("target_key" => "#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        end
        expect(JSON.parse(response.body)["unconfigured_notification_keys"].first)
        .to eq('test_notification_key')
      end
    end

    context "with filter parameter" do
      context "with configured as filter" do
        before do
          @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
          @notification = create(:notification, target: test_target, key: 'test_notification_key')
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'configured' }), valid_session
        end

        it "assigns configured subscription index as @subscriptions" do
          expect(assigns(:subscriptions)).to eq([@subscription])
        end

        it "does not assign unconfigured notification keys as @notification_keys" do
          expect(assigns(:notification_keys)).to be_nil
        end
      end

      context "with unconfigured as filter" do
        before do
          @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
          @notification = create(:notification, target: test_target, key: 'test_notification_key')
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'unconfigured' }), valid_session
        end

        it "does not assign configured subscription index as @subscriptions" do
          expect(assigns(:subscriptions)).to be_nil
        end

        it "assigns unconfigured notification keys as @notification_keys" do
          expect(assigns(:notification_keys)).to eq([@notification.key])
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

        it "assigns subscription index of size 2 as @subscriptions" do
          expect(assigns(:subscriptions).size).to eq(2)
        end

        it "assigns notification key index of size 2 as @notification_keys" do
          expect(assigns(:notification_keys).size).to eq(2)
        end
      end

      context "with 1 as limit" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, limit: 1 }), valid_session
        end

        it "assigns subscription index of size 1 as @subscriptions" do
          expect(assigns(:subscriptions).size).to eq(1)
        end

        it "assigns notification key index of size 1 as @notification_keys" do
          expect(assigns(:notification_keys).size).to eq(1)
        end
      end
    end

    context "with reload parameter" do
      context "with false as reload" do
        before do
          @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
          @notification = create(:notification, target: test_target, key: 'test_notification_key')
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, reload: false }), valid_session
        end
    
        it "returns 200 as http status code" do
          expect(response.status).to eq(200)
        end
  
        it "does not assign subscription index as @subscriptions" do
          expect(assigns(:subscriptions)).to be_nil
        end
  
        it "does not assign unconfigured notification keys as @notification_keys" do
          expect(assigns(:notification_keys)).to be_nil
        end

        it "renders the :index template" do
          expect(response).to render_template :index
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
          expect(assigns(:subscriptions)[0]).to eq(@subscription2)
          expect(assigns(:subscriptions).size).to eq(1)
        end

        it "returns filtered notification keys only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_key: 'test_notification_key_2' }), valid_session
          expect(assigns(:notification_keys)[0]).to eq(@notification2.key)
          expect(assigns(:notification_keys).size).to eq(1)
        end
      end
    end
  end

  describe "POST #create" do
    before do
      expect(test_target.subscriptions.size).to       eq(0)
    end

    context "http direct POST request without optional targets" do
      before do
        post_with_compatibility :create, target_params.merge({
            typed_target_param => test_target,
            "subscription"     => { "key"        => "new_subscription_key",
                                    "subscribing"=> "true",
                                    "subscribing_to_email"=>"true"
                                  }
          }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "creates new subscription of the target" do
        expect(test_target.subscriptions.reload.size).to      eq(1)
        expect(test_target.subscriptions.reload.first.key).to eq("new_subscription_key")
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http direct POST request with optional targets" do
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

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "creates new subscription of the target" do
        expect(test_target.subscriptions.reload.size).to      eq(1)
        created_subscription = test_target.subscriptions.reload.first
        expect(created_subscription.key).to eq("new_subscription_key")
        expect(created_subscription.subscribing_to_optional_target?("base1")).to be_truthy
        expect(created_subscription.subscribing_to_optional_target?("base2")).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :create, target_params.merge({
            typed_target_param => test_target,
            "subscription"     => { "key"        => "new_subscription_key",
                                    "subscribing"=> "true",
                                    "subscribing_to_email"=>"true"
                                  }
          }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "creates new subscription of the target" do
        expect(test_target.subscriptions.reload.size).to      eq(1)
        expect(test_target.subscriptions.reload.first.key).to eq("new_subscription_key")
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :create, target_params.merge({
            typed_target_param => test_target,
            "subscription"     => { "key"        => "new_subscription_key",
                                    "subscribing"=> "true",
                                    "subscribing_to_email"=>"true"
                                  }
          }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([test_target.subscriptions.reload.first])
      end

      it "creates new subscription of the target" do
        expect(test_target.subscriptions.reload.size).to      eq(1)
        expect(test_target.subscriptions.reload.first.key).to eq("new_subscription_key")
      end

      it "renders the :create template as format js" do
        expect(response).to render_template :create, format: :js
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

      it "assigns the requested subscription as @subscription" do
        expect(assigns(:subscription)).to eq(@subscription)
      end

      it "renders the :index template" do
        expect(response).to render_template :show
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
    end
  end

  describe "DELETE #destroy" do
    context "http direct DELETE request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        delete_with_compatibility :destroy, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "deletes the subscription" do
        expect(assigns(test_target.subscriptions.where(id: @subscription.id).exists?)).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http DELETE request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        request.env["HTTP_REFERER"] = root_path
        delete_with_compatibility :destroy, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "deletes the subscription" do
        expect(assigns(test_target.subscriptions.where(id: @subscription.id).exists?)).to be_falsey
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax DELETE request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        xhr_with_compatibility :delete, :destroy, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([])
      end

      it "deletes the subscription" do
        expect(assigns(test_target.subscriptions.where(id: @subscription.id).exists?)).to be_falsey
      end

      it "renders the :destroy template as format js" do
        expect(response).to render_template :destroy, format: :js
      end
    end
  end

  describe "POST #subscribe" do
    context "http direct POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        post_with_compatibility :subscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing to true" do
        expect(@subscription.reload.subscribing?).to be_truthy
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :subscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing to true" do
        expect(@subscription.reload.subscribing?).to be_truthy
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :subscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
  
      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "updates subscribing to true" do
        expect(@subscription.reload.subscribing?).to be_truthy
      end

      it "renders the :open template as format js" do
        expect(response).to render_template :subscribe, format: :js
      end
    end
  end

  describe "POST #unsubscribe" do
    context "http direct POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing?).to be_truthy
        post_with_compatibility :unsubscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing to false" do
        expect(@subscription.reload.subscribing?).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing?).to be_truthy
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :unsubscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing to false" do
        expect(@subscription.reload.subscribing?).to be_falsey
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing?).to be_truthy
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :unsubscribe, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
  
      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "updates subscribing to false" do
        expect(@subscription.reload.subscribing?).to be_falsey
      end

      it "renders the :open template as format js" do
        expect(response).to render_template :unsubscribe, format: :js
      end
    end
  end

  describe "POST #subscribe_to_email" do
    context "http direct POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_email
        expect(@subscription.subscribing_to_email?).to be_falsey
        post_with_compatibility :subscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_email to true" do
        expect(@subscription.reload.subscribing_to_email?).to be_truthy
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_email
        expect(@subscription.subscribing_to_email?).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :subscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_email to true" do
        expect(@subscription.reload.subscribing_to_email?).to be_truthy
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_email
        expect(@subscription.subscribing_to_email?).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :subscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
  
      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "updates subscribing_to_email to true" do
        expect(@subscription.reload.subscribing_to_email?).to be_truthy
      end

      it "renders the :open template as format js" do
        expect(response).to render_template :subscribe_to_email, format: :js
      end
    end

    context "with unsubscribed target" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        expect(@subscription.subscribing_to_email?).to be_falsey
        post_with_compatibility :subscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "cannot update subscribing_to_email to true" do
        expect(@subscription.reload.subscribing_to_email?).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end
  end

  describe "POST #unsubscribe_to_email" do
    context "http direct POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_email?).to be_truthy
        post_with_compatibility :unsubscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_email to false" do
        expect(@subscription.reload.subscribing_to_email?).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_email?).to be_truthy
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :unsubscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_email to false" do
        expect(@subscription.reload.subscribing_to_email?).to be_falsey
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_email?).to be_truthy
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :unsubscribe_to_email, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
  
      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "updates subscribing_to_email to false" do
        expect(@subscription.reload.subscribing_to_email?).to be_falsey
      end

      it "renders the :open template as format js" do
        expect(response).to render_template :unsubscribe_to_email, format: :js
      end
    end
  end

  describe "POST #subscribe_to_optional_target" do
    context "without optional_target_name param" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        post_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end

      it "does not update subscribing_to_optional_target?" do
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
      end
    end

    context "http direct POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        post_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_optional_target to true" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_truthy
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_optional_target to true" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_truthy
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :subscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
  
      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "updates subscribing_to_optional_target to true" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_truthy
      end

      it "renders the :open template as format js" do
        expect(response).to render_template :subscribe_to_optional_target, format: :js
      end
    end

    context "with unsubscribed target" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        @subscription.unsubscribe_to_optional_target(:base)
        @subscription.unsubscribe
        expect(@subscription.subscribing?).to be_falsey
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_falsey
        post_with_compatibility :subscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "cannot update subscribing_to_optional_target to true" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end
  end

  describe "POST #unsubscribe_to_email" do
    context "without optional_target_name param" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
        post_with_compatibility :unsubscribe_to_optional_target, target_params.merge({ id: @subscription, typed_target_param => test_target }), valid_session
      end

      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end

      it "does not update subscribing_to_optional_target?" do
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
      end
    end

    context "http direct POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
        post_with_compatibility :unsubscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_optional_target to false" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :unsubscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "updates subscribing_to_optional_target to false" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @subscription = create(:subscription, target: test_target, key: 'test_subscription_key')
        expect(@subscription.subscribing_to_optional_target?(:base)).to be_truthy
        request.env["HTTP_REFERER"] = root_path
        xhr_with_compatibility :post, :unsubscribe_to_optional_target, target_params.merge({ id: @subscription, optional_target_name: 'base', typed_target_param => test_target }), valid_session
      end
  
      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
  
      it "assigns subscription index as @subscriptions" do
        expect(assigns(:subscriptions)).to eq([@subscription])
      end

      it "updates subscribing_to_optional_target to false" do
        expect(@subscription.reload.subscribing_to_optional_target?(:base)).to be_falsey
      end

      it "renders the :open template as format js" do
        expect(response).to render_template :unsubscribe_to_optional_target, format: :js
      end
    end
  end


  private

    def get_with_compatibility action, params, session
      if Rails::VERSION::MAJOR <= 4
        get action, params, session
      else
        get action, params: params, session: session
      end
    end

    def post_with_compatibility action, params, session
      if Rails::VERSION::MAJOR <= 4
        post action, params, session
      else
        post action, params: params, session: session
      end
    end

    def delete_with_compatibility action, params, session
      if Rails::VERSION::MAJOR <= 4
        delete action, params, session
      else
        delete action, params: params, session: session
      end
    end

    def xhr_with_compatibility method, action, params, session
      if Rails::VERSION::MAJOR <= 4
        xhr method, action, params, session
      else
        send method.to_s, action, xhr: true, params: params, session: session
      end
    end
end
