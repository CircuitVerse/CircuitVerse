describe ActivityNotification::ActsAsTarget do
  let(:dummy_model_class) { Dummy::DummyBase }

  describe "as public class methods" do
    describe ".acts_as_target" do
      it "have not included Target before calling" do
        expect(dummy_model_class.respond_to?(:available_as_target?)).to be_falsey
      end

      it "includes Target" do
        dummy_model_class.acts_as_target
        expect(dummy_model_class.respond_to?(:available_as_target?)).to be_truthy
        expect(dummy_model_class.available_as_target?).to be_truthy
      end

      context "with no options" do
        it "returns hash of specified options" do
          expect(dummy_model_class.acts_as_target).to eq({})
        end
      end
    end

    describe ".acts_as_notification_target" do
      it "is an alias of acts_as_target" do
        expect(dummy_model_class.respond_to?(:acts_as_notification_target)).to be_truthy
      end
    end

    describe ".available_target_options" do
      it "returns list of available options in acts_as_target" do
        expect(dummy_model_class.available_target_options)
          .to eq([:email, :email_allowed, :batch_email_allowed, :subscription_allowed, :action_cable_enabled, :action_cable_with_devise, :devise_resource, :printable_notification_target_name, :printable_name])
      end
    end
  end
end