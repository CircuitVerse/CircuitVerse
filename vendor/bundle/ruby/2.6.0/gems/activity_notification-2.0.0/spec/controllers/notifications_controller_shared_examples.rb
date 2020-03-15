shared_examples_for :notification_controller do
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

      it "assigns notification index as @notifications" do
        expect(assigns(:notifications)).to eq([@notification])
      end

      it "renders the :index template" do
        expect(response).to render_template :index
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

      it "assigns notification index as @notifications" do
        expect(assigns(:notifications)).to eq([@notification])
      end

      it "renders the :index template" do
        expect(response).to render_template :index
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
    end

    context "with not found (typed_target)_id parameter" do
      before do
        @notification = create(:notification, target: test_target)
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
        @notification = create(:notification, target: test_target)
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, format: :json }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "returns json format" do
        case ActivityNotification.config.orm
        when :active_record
          expect(JSON.parse(response.body).first)
          .to include("target_id" => test_target.id, "target_type" => test_target.to_class_name)
        when :mongoid
          expect(JSON.parse(response.body).first)
          .to include("target_id" => test_target.id.to_s, "target_type" => test_target.to_class_name)
        when :dynamoid
          expect(JSON.parse(response.body).first)
          .to include("target_key" => "#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        end
      end
    end

    context "with filter parameter" do
      context "with unopened as filter" do
        before do
          @notification = create(:notification, target: test_target)
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'unopened' }), valid_session
        end

        it "assigns unopened notification index as @notifications" do
          expect(assigns(:notifications)).to eq([@notification])
        end
      end

      context "with opened as filter" do
        before do
          @notification = create(:notification, target: test_target)
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filter: 'opened' }), valid_session
        end

        it "assigns unopened notification index as @notifications" do
          expect(assigns(:notifications)).to eq([])
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

        it "assigns notification index of size 2 as @notifications" do
          expect(assigns(:notifications).size).to eq(2)
        end
      end

      context "with 1 as limit" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, limit: 1 }), valid_session
        end

        it "assigns notification index of size 1 as @notifications" do
          expect(assigns(:notifications).size).to eq(1)
        end
      end
    end

    context "with reload parameter" do
      context "with false as reload" do
        before do
          @notification = create(:notification, target: test_target)
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, reload: false }), valid_session
        end
    
        it "returns 200 as http status code" do
          expect(response.status).to eq(200)
        end
  
        it "does not assign notification index as @notifications" do
          expect(assigns(:notifications)).to be_nil
        end
  
        it "renders the :index template" do
          expect(response).to render_template :index
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
          expect(assigns(:notifications)[0]).to eq(@notification1)
          expect(assigns(:notifications)[1]).to eq(@notification2)
          expect(assigns(:notifications)[2]).to eq(@notification3)
          expect(assigns(:notifications).size).to eq(3)
        end
      end

      context "with true as reverse" do
        before do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, reverse: true }), valid_session
        end

        it "returns the earliest order" do
          expect(assigns(:notifications)[0]).to eq(@notification2)
          expect(assigns(:notifications)[1]).to eq(@notification1)
          expect(assigns(:notifications)[2]).to eq(@notification3)
          expect(assigns(:notifications).size).to eq(3)
        end
      end
    end

    context "with options filter parameters" do
      before do
        @notifiable    = create(:article)
        @group         = create(:article)
        @key           = 'test.key.1'
        @notification2 = create(:notification, target: test_target, notifiable: @notifiable)
        @notification1 = create(:notification, target: test_target, notifiable: create(:comment), group: @group)
        @notification3 = create(:notification, target: test_target, notifiable: create(:article), key: @key)
        @notification3.open!
      end

      context 'with filtered_by_type parameter' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_type: 'Article' }), valid_session
          expect(assigns(:notifications)[0]).to eq(@notification2)
          expect(assigns(:notifications)[1]).to eq(@notification3)
          expect(assigns(:notifications).size).to eq(2)
        end
      end

      context 'with filtered_by_group_type and filtered_by_group_id parameters' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_group_type: 'Article', filtered_by_group_id: @group.id.to_s }), valid_session
          expect(assigns(:notifications)[0]).to eq(@notification1)
          expect(assigns(:notifications).size).to eq(1)
        end
      end

      context 'with filtered_by_key parameter' do
        it "returns filtered notifications only" do
          get_with_compatibility :index, target_params.merge({ typed_target_param => test_target, filtered_by_key: @key }), valid_session
          expect(assigns(:notifications)[0]).to eq(@notification3)
          expect(assigns(:notifications).size).to eq(1)
        end
      end
    end
  end

  describe "POST #open_all" do
    context "http direct POST request" do
      before do
        @notification = create(:notification, target: test_target)
        expect(@notification.opened?).to be_falsey
        post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "opens all notifications of the target" do
        expect(@notification.reload.opened?).to be_truthy
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http POST request from root_path" do
      before do
        @notification = create(:notification, target: test_target)
        expect(@notification.opened?).to be_falsey
        request.env["HTTP_REFERER"] = root_path
        post_with_compatibility :open_all, target_params.merge({ typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "opens all notifications of the target" do
        expect(@notification.reload.opened?).to be_truthy
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax POST request" do
      before do
        @notification = create(:notification, target: test_target)
        expect(@notification.opened?).to be_falsey
        xhr_with_compatibility :post, :open_all, target_params.merge({ typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "assigns notification index as @notifications" do
        expect(assigns(:notifications)).to eq([@notification])
      end

      it "opens all notifications of the target" do
        expect(assigns(:notifications).first.opened?).to be_truthy
      end

      it "renders the :open_all template as format js" do
        expect(response).to render_template :open_all, format: :js
      end
    end

    context "with filter request parameters" do
      before do
        @target_1, @notifiable_1, @group_1, @key_1 = create(:confirmed_user), create(:article), nil,           "key.1"
        @target_2, @notifiable_2, @group_2, @key_2 = create(:confirmed_user), create(:comment), @notifiable_1, "key.2"
        @notification_1 = create(:notification, target: test_target, notifiable: @notifiable_1, group: @group_1, key: @key_1)
        @notification_2 = create(:notification, target: test_target, notifiable: @notifiable_2, group: @group_2, key: @key_2)
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

      it "assigns the requested notification as @notification" do
        expect(assigns(:notification)).to eq(@notification)
      end

      it "renders the :index template" do
        expect(response).to render_template :show
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
    end
  end

  describe "DELETE #destroy" do
    context "http direct DELETE request" do
      before do
        @notification = create(:notification, target: test_target)
        delete_with_compatibility :destroy, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "deletes the notification" do
        expect(assigns(test_target.notifications.where(id: @notification.id).exists?)).to be_falsey
      end

      it "redirects to :index" do
        expect(response).to redirect_to action: :index
      end
    end

    context "http DELETE request from root_path" do
      before do
        @notification = create(:notification, target: test_target)
        request.env["HTTP_REFERER"] = root_path
        delete_with_compatibility :destroy, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "deletes the notification" do
        expect(assigns(test_target.notifications.where(id: @notification.id).exists?)).to be_falsey
      end

      it "redirects to root_path as request.referer" do
        expect(response).to redirect_to root_path
      end
    end

    context "Ajax DELETE request" do
      before do
        @notification = create(:notification, target: test_target)
        xhr_with_compatibility :delete, :destroy, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end

      it "assigns notification index as @notifications" do
        expect(assigns(:notifications)).to eq([])
      end

      it "deletes the notification" do
        expect(assigns(test_target.notifications.where(id: @notification.id).exists?)).to be_falsey
      end

      it "renders the :destroy template as format js" do
        expect(response).to render_template :destroy, format: :js
      end
    end
  end

  describe "POST #open" do
    context "without move parameter" do
      context "http direct POST request" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          post_with_compatibility :open, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
        end

        it "returns 302 as http status code" do
          expect(response.status).to eq(302)
        end

        it "opens the notification" do
          expect(@notification.reload.opened?).to be_truthy
        end

        it "redirects to :index" do
          expect(response).to redirect_to action: :index
        end
      end

      context "http POST request from root_path" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          request.env["HTTP_REFERER"] = root_path
          post_with_compatibility :open, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
        end

        it "returns 302 as http status code" do
          expect(response.status).to eq(302)
        end

        it "opens the notification" do
          expect(@notification.reload.opened?).to be_truthy
        end

        it "redirects to root_path as request.referer" do
          expect(response).to redirect_to root_path
        end
      end

      context "Ajax POST request" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          request.env["HTTP_REFERER"] = root_path
          xhr_with_compatibility :post, :open, target_params.merge({ id: @notification, typed_target_param => test_target }), valid_session
        end
    
        it "returns 200 as http status code" do
          expect(response.status).to eq(200)
        end
    
        it "assigns notification index as @notifications" do
          expect(assigns(:notifications)).to eq([@notification])
        end
  
        it "opens the notification" do
          expect(@notification.reload.opened?).to be_truthy
        end
  
        it "renders the :open template as format js" do
          expect(response).to render_template :open, format: :js
        end
      end
    end

    context "with true as move parameter" do
      context "http direct POST request" do
        before do
          @notification = create(:notification, target: test_target)
          expect(@notification.opened?).to be_falsey
          post_with_compatibility :open, target_params.merge({ id: @notification, typed_target_param => test_target, move: true }), valid_session
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
      context "http direct GET request" do
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
      context "http direct GET request" do
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
