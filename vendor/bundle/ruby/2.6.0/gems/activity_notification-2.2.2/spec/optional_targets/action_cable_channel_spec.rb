require 'activity_notification/optional_targets/action_cable_channel'
describe ActivityNotification::OptionalTarget::ActionCableChannel do
  let(:test_instance) { ActivityNotification::OptionalTarget::ActionCableChannel.new(skip_initializing_target: true) }

  describe "as public instance methods" do
    describe "#to_optional_target_name" do
      it "is return demodulized symbol class name" do
        expect(test_instance.to_optional_target_name).to eq(:action_cable_channel)
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
        it "renders notification message with default template" do
          expect(test_instance.send(:render_notification_message, create(:notification))).to be_include("<div class='notification_list") 
        end
      end

      context "with unexisting template as fallback option" do
        it "raise ActionView::MissingTemplate" do
          expect { expect(test_instance.send(:render_notification_message, create(:notification), fallback: :hoge)) }
            .to raise_error(ActionView::MissingTemplate)
        end
      end
    end
  end
end
