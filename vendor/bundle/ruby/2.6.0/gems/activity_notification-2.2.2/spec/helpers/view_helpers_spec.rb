describe ActivityNotification::ViewHelpers, type: :helper do
  let(:view_context)         { ActionView::Base.new(ActionView::LookupContext.new(ActionController::Base.view_paths), [], nil) }
  let(:notification)         {
    create(:notification, target: create(:confirmed_user))
  }
  let(:target_user)          { notification.target }
  let(:subscription)         {
    create(:subscription, target: target_user, key: notification.key)
  }
  let(:notification_2)       {
    create(:notification, target: create(:confirmed_user))
  }
  let(:notifications)        {
    target = create(:confirmed_user)
    create(:notification, target: target)
    create(:notification, target: target)
    target.notifications.group_owners_only
  }
  let(:simple_text_key)      { 'article.create' }
  let(:simple_text_original) { 'Article has been created' }

  include ActivityNotification::ViewHelpers

  describe 'ActionView::Base' do
    it 'provides render_notification helper' do
      expect(view_context.respond_to?(:render_notification)).to be_truthy
    end
  end

  describe '.render_notification' do
    context "without fallback" do
      context "when the template is missing for the target type and key" do
        it "raises ActionView::MissingTemplate" do
          expect { render_notification notification }
            .to raise_error(ActionView::MissingTemplate)
        end
      end
    end

    context "with default as fallback" do
      it "renders default notification view" do
        expect(render_notification notification, fallback: :default)
          .to eq(
            render partial: 'activity_notification/notifications/default/default',
                   locals: { notification: notification, parameters: {} }
          )
      end

      it 'handles multiple notifications of records' do
        rendered_template = render_notification notifications, fallback: :default
        expect(rendered_template).to start_with(
          render partial: 'activity_notification/notifications/default/default',
                 locals: { notification: notifications.to_a.first, parameters: {} })
        expect(rendered_template).to end_with(
          render partial: 'activity_notification/notifications/default/default',
                 locals: { notification: notifications.to_a.last , parameters: {} })
      end

      it 'handles multiple notifications of array' do
        expect(notification).to receive(:render).with(self, { fallback: :default })
        expect(notification_2).to receive(:render).with(self, { fallback: :default })
        render_notification [notification, notification_2], fallback: :default
      end
    end

    context "with text as fallback" do
      it "uses i18n text from key" do
        notification.key = simple_text_key
        expect(render_notification notification, fallback: :text)
          .to eq(simple_text_original)
      end

      it "interpolates from parameters" do
        notification.parameters = { "article_title" => "custom title" }
        notification.key = 'article.destroy'
        expect(render_notification notification, fallback: :text)
          .to eq('The author removed an article "custom title"')
      end
    end

    context "with i18n param set" do
      it "uses i18n text from key" do
        notification.key = simple_text_key
        expect(render_notification notification, i18n: true)
          .to eq(simple_text_original)
      end
    end

    context "with custom view" do
      it "renders custom notification view for default target" do
        notification.key = 'custom.test'
        # render activity_notification/notifications/default/custom/test
        expect(render_notification notification)
          .to eq("Custom template root for default target: #{notification.id}")
      end

      it "renders custom notification view for specified target" do
        notification.key = 'custom.test'
        # render activity_notification/notifications/users/custom/test
        expect(render_notification notification, target: :users)
          .to eq("Custom template root for user target: #{notification.id}")
      end

      it "renders custom notification view of partial parameter" do
        notification.key = 'custom.test'
        # render activity_notification/notifications/default/custom/path_test
        expect(render_notification notification, partial: 'custom/path_test')
          .to eq("Custom template root for path test: #{notification.id}")
      end

      it "uses layout of layout parameter" do
        notification.key = 'custom.test'
        expect(self).to receive(:render).with({
          layout:  'layouts/test',
          partial: 'activity_notification/notifications/default/custom/test',
          assigns: {},
          locals:  notification.prepare_locals({ layout: 'test' })
        })
        render_notification notification, layout: 'test'
      end

      context "with defined overriding_notification_template_key in notifiable model" do
        it "renders overridden custom notification view" do
          notification.key = 'custom.test'
          module AdditionalMethods
            def overriding_notification_template_key(target, key)
              'overridden.custom.test'
            end
          end
          notification.notifiable.extend(AdditionalMethods)
          # render activity_notification/notifications/users/overridden/custom/test
          expect(render_notification notification, target: :users)
            .to eq("Overridden custom template root for user target: #{notification.id}")
        end
      end
    end
  end

  describe '.render_notifications' do
    it "is an alias of render_notification" do
      expect(notification).to receive(:render).with(self, { fallback: :default })
      render_notifications notification, fallback: :default
    end
  end

  describe '.render_notification_of' do
    context "without fallback" do
      context "when the template is missing for the target type and key" do
        it "raises ActionView::MissingTemplate" do
          expect { render_notification_of target_user }
            .to raise_error(ActionView::MissingTemplate)
        end
      end
    end

    context "with default as fallback" do
      it "renders default notification view" do
        allow(self).to receive(:content_for).with(:notification_index).and_return('foo')
        @target = target_user
        expect(render_notification_of target_user, fallback: :default)
          .to eq(
            render partial: 'activity_notification/notifications/default/index',
                   locals: { target: target_user, parameters: { fallback: :default } }
          )
      end
    end

    context "with custom view" do
      before do
        allow(self).to receive(:content_for).with(:notification_index).and_return('foo')
        @target = target_user
      end

      it "renders custom notification view for specified target" do
        expect(render_notification_of target_user, partial: 'custom_index', fallback: :default).to eq("Custom index: ")
      end

      it "uses layout of layout parameter" do
        expect(self).to receive(:render).with({
          partial: 'activity_notification/notifications/users/index',
          layout:  'layouts/test',
          locals:  { target: target_user, parameters: {} }
        })
        render_notification_of target_user, layout: 'test'
      end
    end

    context "with index_content option" do
      before do
        @target = target_user
      end

      context "as default" do
        it "uses target.notification_index_with_attributes" do
          expect(target_user).to receive(:notification_index_with_attributes)
          render_notification_of target_user
        end
      end

      context "with :simple" do
        it "uses target.notification_index" do
          expect(target_user).to receive(:notification_index)
          render_notification_of target_user, index_content: :simple
        end
      end

      context "with :unopened_simple" do
        it "uses target.unopened_notification_index" do
          expect(target_user).to receive(:unopened_notification_index).at_least(:once)
          render_notification_of target_user, index_content: :unopened_simple
        end
      end

      context "with :opened_simple" do
        it "uses target.opened_notification_index" do
          expect(target_user).to receive(:opened_notification_index).at_least(:once)
          render_notification_of target_user, index_content: :opened_simple
        end
      end

      context "with :with_attributes" do
        it "uses target.notification_index_with_attributes" do
          expect(target_user).to receive(:notification_index_with_attributes)
          render_notification_of target_user, index_content: :with_attributes
        end
      end

      context "with :unopened_with_attributes" do
        it "uses target.unopened_notification_index_with_attributes" do
          expect(target_user).to receive(:unopened_notification_index_with_attributes).at_least(:once)
          render_notification_of target_user, index_content: :unopened_with_attributes
        end
      end

      context "with :opened_with_attributes" do
        it "uses target.opened_notification_index_with_attributes" do
          expect(target_user).to receive(:opened_notification_index_with_attributes).at_least(:once)
          render_notification_of target_user, index_content: :opened_with_attributes
        end
      end

      context "with :none" do
        it "uses neither target.notification_index nor notification_index_with_attributes" do
          expect(target_user).not_to receive(:notification_index)
          expect(target_user).not_to receive(:notification_index_with_attributes)
          render_notification_of target_user, index_content: :none
        end
      end

      context "with any other key" do
        it "uses target.notification_index_with_attributes" do
          expect(target_user).to receive(:notification_index_with_attributes)
          render_notification_of target_user, index_content: :hoge
        end
      end

    end
  end

  describe '#render_notifications_of' do
    it "is an alias of render_notification_of" do
      expect(self).to receive(:render_notification)
      render_notifications_of target_user, fallback: :default
    end
  end

  describe '#notifications_path_for' do
    it "returns path for the notification target" do
      expect(notifications_path_for(target_user))
        .to eq(user_notifications_path(target_user))
    end
  end

  describe '#notification_path_for' do
    it "returns path for the notification target" do
      expect(notification_path_for(notification))
        .to eq(user_notification_path(target_user, notification))
    end
  end

  describe '#move_notification_path_for' do
    it "returns path for the notification target" do
      expect(move_notification_path_for(notification))
        .to eq(move_user_notification_path(target_user, notification))
    end
  end

  describe '#open_notification_path_for' do
    it "returns path for the notification target" do
      expect(open_notification_path_for(notification))
        .to eq(open_user_notification_path(target_user, notification))
    end
  end

  describe '#open_all_notifications_path_for' do
    it "returns path for the notification target" do
      expect(open_all_notifications_path_for(target_user))
        .to eq(open_all_user_notifications_path(target_user))
    end
  end

  describe '#notifications_url_for' do
    it "returns url for the notification target" do
      expect(notifications_url_for(target_user))
        .to eq(user_notifications_url(target_user))
    end
  end

  describe '#notification_url_for' do
    it "returns url for the notification target" do
      expect(notification_url_for(notification))
        .to eq(user_notification_url(target_user, notification))
    end
  end

  describe '#move_notification_url_for' do
    it "returns url for the notification target" do
      expect(move_notification_url_for(notification))
        .to eq(move_user_notification_url(target_user, notification))
    end
  end

  describe '#open_notification_url_for' do
    it "returns url for the notification target" do
      expect(open_notification_url_for(notification))
        .to eq(open_user_notification_url(target_user, notification))
    end
  end

  describe '#open_all_notifications_url_for' do
    it "returns url for the notification target" do
      expect(open_all_notifications_url_for(target_user))
        .to eq(open_all_user_notifications_url(target_user))
    end
  end

  describe '#subscriptions_path_for' do
    it "returns path for the subscription target" do
      expect(subscriptions_path_for(target_user))
        .to eq(user_subscriptions_path(target_user))
    end
  end

  describe '#subscription_path_for' do
    it "returns path for the subscription target" do
      expect(subscription_path_for(subscription))
        .to eq(user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscribe_subscription_path_for' do
    it "returns path for the subscription target" do
      expect(subscribe_subscription_path_for(subscription))
        .to eq(subscribe_user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscribe_path_for' do
    it "returns path for the subscription target" do
      expect(subscribe_path_for(subscription))
        .to eq(subscribe_user_subscription_path(target_user, subscription))
    end
  end

  describe '#unsubscribe_subscription_path_for' do
    it "returns path for the subscription target" do
      expect(unsubscribe_subscription_path_for(subscription))
        .to eq(unsubscribe_user_subscription_path(target_user, subscription))
    end
  end

  describe '#unsubscribe_path_for' do
    it "returns path for the subscription target" do
      expect(unsubscribe_path_for(subscription))
        .to eq(unsubscribe_user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscribe_to_email_subscription_path_for' do
    it "returns path for the subscription target" do
      expect(subscribe_to_email_subscription_path_for(subscription))
        .to eq(subscribe_to_email_user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscribe_to_email_path_for' do
    it "returns path for the subscription target" do
      expect(subscribe_to_email_path_for(subscription))
        .to eq(subscribe_to_email_user_subscription_path(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_email_subscription_path_for' do
    it "returns path for the subscription target" do
      expect(unsubscribe_to_email_subscription_path_for(subscription))
        .to eq(unsubscribe_to_email_user_subscription_path(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_email_path_for' do
    it "returns path for the subscription target" do
      expect(unsubscribe_to_email_path_for(subscription))
        .to eq(unsubscribe_to_email_user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscribe_to_optional_target_subscription_path_for' do
    it "returns path for the subscription target" do
      expect(subscribe_to_optional_target_subscription_path_for(subscription))
        .to eq(subscribe_to_optional_target_user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscribe_to_optional_target_path_for' do
    it "returns path for the subscription target" do
      expect(subscribe_to_optional_target_path_for(subscription))
        .to eq(subscribe_to_optional_target_user_subscription_path(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_optional_target_subscription_path_for' do
    it "returns path for the subscription target" do
      expect(unsubscribe_to_optional_target_subscription_path_for(subscription))
        .to eq(unsubscribe_to_optional_target_user_subscription_path(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_optional_target_path_for' do
    it "returns path for the subscription target" do
      expect(unsubscribe_to_optional_target_path_for(subscription))
        .to eq(unsubscribe_to_optional_target_user_subscription_path(target_user, subscription))
    end
  end

  describe '#subscriptions_url_for' do
    it "returns url for the subscription target" do
      expect(subscriptions_url_for(target_user))
        .to eq(user_subscriptions_url(target_user))
    end
  end

  describe '#subscription_url_for' do
    it "returns url for the subscription target" do
      expect(subscription_url_for(subscription))
        .to eq(user_subscription_url(target_user, subscription))
    end
  end

  describe '#subscribe_subscription_url_for' do
    it "returns url for the subscription target" do
      expect(subscribe_subscription_url_for(subscription))
        .to eq(subscribe_user_subscription_url(target_user, subscription))
    end
  end

  describe '#subscribe_url_for' do
    it "returns url for the subscription target" do
      expect(subscribe_url_for(subscription))
        .to eq(subscribe_user_subscription_url(target_user, subscription))
    end
  end

  describe '#unsubscribe_subscription_url_for' do
    it "returns url for the subscription target" do
      expect(unsubscribe_subscription_url_for(subscription))
        .to eq(unsubscribe_user_subscription_url(target_user, subscription))
    end
  end

  describe '#unsubscribe_url_for' do
    it "returns url for the subscription target" do
      expect(unsubscribe_url_for(subscription))
        .to eq(unsubscribe_user_subscription_url(target_user, subscription))
    end
  end

  describe '#subscribe_to_email_subscription_url_for' do
    it "returns url for the subscription target" do
      expect(subscribe_to_email_subscription_url_for(subscription))
        .to eq(subscribe_to_email_user_subscription_url(target_user, subscription))
    end
  end

  describe '#subscribe_to_email_url_for' do
    it "returns url for the subscription target" do
      expect(subscribe_to_email_url_for(subscription))
        .to eq(subscribe_to_email_user_subscription_url(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_email_subscription_url_for' do
    it "returns url for the subscription target" do
      expect(unsubscribe_to_email_subscription_url_for(subscription))
        .to eq(unsubscribe_to_email_user_subscription_url(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_email_url_for' do
    it "returns url for the subscription target" do
      expect(unsubscribe_to_email_url_for(subscription))
        .to eq(unsubscribe_to_email_user_subscription_url(target_user, subscription))
    end
  end

  describe '#subscribe_to_optional_target_subscription_url_for' do
    it "returns url for the subscription target" do
      expect(subscribe_to_optional_target_subscription_url_for(subscription))
        .to eq(subscribe_to_optional_target_user_subscription_url(target_user, subscription))
    end
  end

  describe '#subscribe_to_optional_target_url_for' do
    it "returns url for the subscription target" do
      expect(subscribe_to_optional_target_url_for(subscription))
        .to eq(subscribe_to_optional_target_user_subscription_url(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_optional_target_subscription_url_for' do
    it "returns url for the subscription target" do
      expect(unsubscribe_to_optional_target_subscription_url_for(subscription))
        .to eq(unsubscribe_to_optional_target_user_subscription_url(target_user, subscription))
    end
  end

  describe '#unsubscribe_to_optional_target_url_for' do
    it "returns url for the subscription target" do
      expect(unsubscribe_to_optional_target_url_for(subscription))
        .to eq(unsubscribe_to_optional_target_user_subscription_url(target_user, subscription))
    end
  end

end
