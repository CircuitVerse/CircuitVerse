require 'channels/notification_api_channel_shared_examples'

# @See https://github.com/palkan/action-cable-testing
describe ActivityNotification::NotificationApiWithDeviseChannel, type: :channel do
  let(:test_user)            { create(:confirmed_user) }
  let(:unauthenticated_user) { create(:confirmed_user) }
  let(:test_target)          { create(:admin, user: test_user) }
  let(:target_type)          { "Admin" }
  let(:typed_target_param)   { "admin_id" }
  let(:extra_params)         { { devise_type: :users } }
  let(:valid_session)        {}

  # @See https://github.com/lynndylanhurley/devise_token_auth
  def sign_in(current_target)
    @auth_headers = current_target.create_new_auth_token
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
  
    it_behaves_like :notification_api_channel
  end

  context "signed in with devise as unauthenticated user" do
    let(:target_params) { { target_type: target_type, devise_type: :users } }

    before do
      sign_in unauthenticated_user
    end

    it "rejects subscription" do
      subscribe(target_params.merge({ typed_target_param => test_target }).merge(@auth_headers))
      expect(subscription).to be_rejected
      expect {
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_api_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
      }.to raise_error(/Must be subscribed!/)
    end
  end

  context "unsigned in with devise" do
    let(:target_params) { { target_type: target_type, devise_type: :users } }

    it "rejects subscription" do
      subscribe(target_params.merge({ typed_target_param => test_target }))
      expect(subscription).to be_rejected
      expect {
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_api_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
      }.to raise_error(/Must be subscribed!/)
    end
  end

  context "without target_id and (typed_target)_id parameters for devise integrated channel with devise_type option" do
    let(:target_params) { { target_type: target_type, devise_type: :users } }

    before do
      sign_in test_target.user
    end

    it "successfully subscribes" do
      subscribe(target_params.merge(@auth_headers))
      expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_api_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
      expect(subscription).to have_stream_from("activity_notification_api_channel_Admin##{test_target.id}")
    end
  end
end
