require 'activity_notification/optional_targets/action_cable_api_channel'
describe ActivityNotification::OptionalTarget::ActionCableApiChannel do
  let(:test_instance) { ActivityNotification::OptionalTarget::ActionCableApiChannel.new(skip_initializing_target: true) }

  describe "as public instance methods" do
    describe "#to_optional_target_name" do
      it "is return demodulized symbol class name" do
        expect(test_instance.to_optional_target_name).to eq(:action_cable_api_channel)
      end
    end

    describe "#initialize_target" do
      it "does not raise NotImplementedError" do
        test_instance.initialize_target
      end
    end

    describe "#notify" do
      it "does not raise NotImplementedError" do
        test_instance.notify(create(:notification))
      end
    end
  end

  describe "as protected instance methods" do
    describe "#render_notification_message" do
      context "as default" do
        it "renders notification message as formatted JSON" do
          expect(test_instance.send(:render_notification_message, create(:notification)).with_indifferent_access[:notification].has_key?(:id)).to be_truthy
        end
      end
    end
  end
end
