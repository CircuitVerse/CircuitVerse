if Rails::VERSION::MAJOR >= 5
  require 'channels/notification_channel_shared_examples'

  #TODO Make it more smart test method
  module ActivityNotification
    module Test
      class NotificationWithDeviseChannel < ::ActivityNotification::NotificationWithDeviseChannel
        @@custom_current_target = nil

        def set_custom_current_target(custom_current_target)
          @@custom_current_target = custom_current_target
        end

        def find_current_target(devise_type = nil)
          super(devise_type)
        rescue NoMethodError
          devise_type = (devise_type || @target.notification_devise_resource.class.name).to_s
          @@custom_current_target.is_a?(devise_type.to_model_class) ? @@custom_current_target : nil
        end
      end
    end
  end

  # @See https://github.com/palkan/action-cable-testing
  describe ActivityNotification::Test::NotificationWithDeviseChannel, type: :channel do
    let(:test_user)            { create(:confirmed_user) }
    let(:unauthenticated_user) { create(:confirmed_user) }
    let(:test_target)          { create(:admin, user: test_user) }
    let(:target_type)          { "Admin" }
    let(:typed_target_param)   { "admin_id" }
    let(:extra_params)         { { devise_type: :users } }
    let(:valid_session)        {}

    #TODO Make it more smart test method
    #include Devise::Test::IntegrationHelpers
    def sign_in(current_target)
      described_class.new(ActionCable::Channel::ConnectionStub.new, {}).set_custom_current_target(current_target)
    end

    before do
      @user_notification_action_cable_with_devise = User._notification_action_cable_with_devise
      User._notification_action_cable_with_devise = true
    end

    after do
      User._notification_action_cable_with_devise = @user_notification_action_cable_with_devise
    end

    context "signed in with devise as authenticated user" do
      before do
        sign_in test_user
      end
    
      it_behaves_like :notification_channel
    end

    context "signed in with devise as unauthenticated user" do
      let(:target_params) { { target_type: target_type, devise_type: :users } }

      before do
        sign_in unauthenticated_user
      end

      it "rejects subscription" do
        subscribe(target_params.merge({ typed_target_param => test_target }))
        expect(subscription).to be_rejected
        expect {
          expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        }.to raise_error(/Must be subscribed!/)
      end
    end

    context "unsigned in with devise" do
      let(:target_params) { { target_type: target_type, devise_type: :users } }

      it "rejects subscription" do
        subscribe(target_params.merge({ typed_target_param => test_target }))
        expect(subscription).to be_rejected
        expect {
          expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        }.to raise_error(/Must be subscribed!/)
      end
    end

    context "without target_id and (typed_target)_id parameters for devise integrated channel with devise_type option" do
      let(:target_params) { { target_type: target_type, devise_type: :users } }

      before do
        sign_in test_target.user
      end

      it "successfully subscribes" do
        subscribe(target_params)
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
        expect(subscription).to have_stream_from("activity_notification_channel_Admin##{test_target.id}")
      end
    end
  end
end
