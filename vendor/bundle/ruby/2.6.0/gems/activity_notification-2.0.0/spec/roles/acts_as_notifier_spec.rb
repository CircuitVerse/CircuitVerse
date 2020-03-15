describe ActivityNotification::ActsAsNotifier do
  let(:dummy_model_class) { Dummy::DummyBase }

  describe "as public class methods" do
    describe ".acts_as_notifier" do
      it "have not included Notifier before calling" do
        expect(dummy_model_class.respond_to?(:available_as_notifier?)).to be_falsey
      end

      it "includes Notifier" do
        dummy_model_class.acts_as_notifier
        expect(dummy_model_class.respond_to?(:available_as_notifier?)).to be_truthy
        expect(dummy_model_class.available_as_notifier?).to be_truthy
      end

      context "with no options" do
        it "returns hash of specified options" do
          expect(dummy_model_class.acts_as_notifier).to eq({})
        end
      end

      #TODO test other options
    end

    describe ".available_notifier_options" do
      it "returns list of available options in acts_as_group" do
        expect(dummy_model_class.available_notifier_options)
          .to eq([:printable_notifier_name, :printable_name])
      end
    end
  end
end