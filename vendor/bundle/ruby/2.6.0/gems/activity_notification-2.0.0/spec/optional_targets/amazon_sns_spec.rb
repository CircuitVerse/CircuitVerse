require 'activity_notification/optional_targets/amazon_sns'
describe ActivityNotification::OptionalTarget::AmazonSNS do
  let(:test_instance) { ActivityNotification::OptionalTarget::AmazonSNS.new(skip_initializing_target: true) }

  describe "as public instance methods" do
    describe "#to_optional_target_name" do
      it "is return demodulized symbol class name" do
        expect(test_instance.to_optional_target_name).to eq(:amazon_sns)
      end
    end

    describe "#initialize_target" do
      #TODO
      it "does not raise NotImplementedError" do
        begin
          test_instance.initialize_target
        rescue Aws::Errors::MissingRegionError
          # Rescue for CI without AWS client configuration
        end
      end
    end

    describe "#notify" do
      #TODO
      it "does not raise NotImplementedError but NoMethodError" do
        expect { test_instance.notify(create(:notification)) }
          .to raise_error(NoMethodError)
      end
    end
  end

  describe "as protected instance methods" do
    describe "#render_notification_message" do
      context "as default" do
        it "renders notification message with default template" do
          expect(test_instance.send(:render_notification_message, create(:notification))).to be_include("Move to notified") 
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
