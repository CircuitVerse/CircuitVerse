# @See https://github.com/palkan/action-cable-testing
shared_examples_for :notification_channel do
  let(:target_params) { { target_type: target_type }.merge(extra_params || {}) }

  before { stub_connection }

  context "with target_type and target_id parameters" do
    it "successfully subscribes" do
      subscribe(target_params.merge({ target_id: test_target.id, typed_target_param => 'dummy' }))
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
    end
  end

  context "with target_type and (typed_target)_id parameters" do
    it "successfully subscribes" do
      subscribe(target_params.merge({ typed_target_param => test_target.id }))
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
    end
  end

  context "without any parameters" do
    it "rejects subscription" do
      subscribe
      expect(subscription).to be_rejected
      expect {
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
      }.to raise_error(/Must be subscribed!/)
    end
  end

  context "without target_type parameter" do
    it "rejects subscription" do
      subscribe({ typed_target_param => test_target.id })
      expect(subscription).to be_rejected
      expect {
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
      }.to raise_error(/Must be subscribed!/)
    end
  end

  context "without target_id and (typed_target)_id parameters" do
    it "rejects subscription" do
      subscribe(target_params)
      expect(subscription).to be_rejected
    end
  end

  context "with not found (typed_target)_id parameter" do
    it "rejects subscription" do
      subscribe(target_params.merge({ typed_target_param => 0 }))
      expect(subscription).to be_rejected
      expect {
        expect(subscription).to have_stream_from("#{ActivityNotification.config.notification_channel_prefix}_#{test_target.to_class_name}#{ActivityNotification.config.composite_key_delimiter}#{test_target.id}")
      }.to raise_error(/Must be subscribed!/)
    end
  end
end
