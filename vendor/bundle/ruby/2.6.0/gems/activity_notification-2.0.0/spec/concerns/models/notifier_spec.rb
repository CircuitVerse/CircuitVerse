shared_examples_for :notifier do
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }

  describe "with association" do
    it "has many sent_notifications" do
      notification_1 = create(:notification, notifier: test_instance)
      notification_2 = create(:notification, notifier: test_instance, created_at: notification_1.created_at + 10.second)
      expect(test_instance.sent_notifications.count).to    eq(2)
      expect(test_instance.sent_notifications.earliest).to eq(notification_1)
      expect(test_instance.sent_notifications.latest).to   eq(notification_2)
    end
  end    

  describe "as public class methods" do
    describe ".available_as_notifier?" do
      it "returns true" do
        expect(described_class.available_as_notifier?).to be_truthy
      end
    end

    describe ".set_notifier_class_defaults" do
      it "set parameter fields as default" do
        described_class.set_notifier_class_defaults
        expect(described_class._printable_notifier_name).to eq(:printable_name)
      end
    end
  end

  describe "as public instance methods" do
    before do
      described_class.set_notifier_class_defaults
    end

    describe "#printable_notifier_name" do
      context "without any configuration" do
        it "returns ActivityNotification::Common.printable_name" do
          expect(test_instance.printable_notifier_name).to eq(test_instance.printable_name)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._printable_notifier_name = 'test_printable_name'
          expect(test_instance.printable_notifier_name).to eq('test_printable_name')
        end

        it "returns specified symbol of field" do
          described_class._printable_notifier_name = :name
          expect(test_instance.printable_notifier_name).to eq(test_instance.name)
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            def custom_printable_name
              'test_printable_name'
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._printable_notifier_name = :custom_printable_name
          expect(test_instance.printable_notifier_name).to eq('test_printable_name')
        end

        it "returns specified lambda with single target argument" do
          described_class._printable_notifier_name = ->(target){ 'test_printable_name' }
          expect(test_instance.printable_notifier_name).to eq('test_printable_name')
        end
      end
    end
  end
end