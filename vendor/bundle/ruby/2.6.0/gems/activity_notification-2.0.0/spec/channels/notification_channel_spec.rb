if Rails::VERSION::MAJOR >= 5
  require 'channels/notification_channel_shared_examples'

  # @See https://github.com/palkan/action-cable-testing
  describe ActivityNotification::NotificationChannel, type: :channel do
    let(:test_target)        { create(:user) }
    let(:target_type)        { "User" }
    let(:typed_target_param) { "user_id" }
    let(:extra_params)       { {} }

    context "when target.notification_action_cable_with_devise? returns true" do
      before do
        @user_notification_action_cable_with_devise = User._notification_action_cable_with_devise
        User._notification_action_cable_with_devise = true
      end

      after do
        User._notification_action_cable_with_devise = @user_notification_action_cable_with_devise
      end

      it "rejects subscription even if target_type and target_id parameters are passed" do
        subscribe({ target_type: target_type, target_id: test_target.id })
        expect(subscription).to be_rejected
        expect {
          expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        }.to raise_error(/Must be subscribed!/)
      end
    end

    context "when target.notification_action_cable_with_devise? returns false" do
      before do
        @user_notification_action_cable_with_devise = User._notification_action_cable_with_devise
        User._notification_action_cable_with_devise = false
      end

      after do
        User._notification_action_cable_with_devise = @user_notification_action_cable_with_devise
      end

      it "successfully subscribes with target_type and target_id parameters" do
        subscribe({ target_type: target_type, target_id: test_target.id })
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        expect(subscription).to have_stream_from("activity_notification_channel_User##{test_target.id}")
      end

      it_behaves_like :notification_channel
    end
  end
end