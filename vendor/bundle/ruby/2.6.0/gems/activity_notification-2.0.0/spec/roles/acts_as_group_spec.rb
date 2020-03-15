describe ActivityNotification::ActsAsGroup do
  let(:dummy_model_class) { Dummy::DummyBase }

  describe "as public class methods" do
    describe ".acts_as_group" do
      it "have not included Group before calling" do
        expect(dummy_model_class.respond_to?(:available_as_group?)).to be_falsey
      end

      it "includes Group" do
        dummy_model_class.acts_as_group
        expect(dummy_model_class.respond_to?(:available_as_group?)).to be_truthy
        expect(dummy_model_class.available_as_group?).to be_truthy
      end

      context "with no options" do
        it "returns hash of specified options" do
          expect(dummy_model_class.acts_as_group).to eq({})
        end
      end

      #TODO test other options
    end

    describe ".available_group_options" do
      it "returns list of available options in acts_as_group" do
        expect(dummy_model_class.available_group_options)
          .to eq([:printable_notification_group_name, :printable_name])
      end
    end
  end
end