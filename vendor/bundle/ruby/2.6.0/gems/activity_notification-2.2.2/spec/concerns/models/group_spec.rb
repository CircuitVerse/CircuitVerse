shared_examples_for :group do
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }

  describe "as public class methods" do
    describe ".available_as_group?" do
      it "returns true" do
        expect(described_class.available_as_group?).to be_truthy
      end
    end

    describe ".set_group_class_defaults" do
      it "set parameter fields as default" do
        described_class.set_group_class_defaults
        expect(described_class._printable_notification_group_name).to eq(:printable_name)
      end
    end    
  end

  describe "as public instance methods" do
    before do
      described_class.set_group_class_defaults
    end

    describe "#printable_group_name" do
      context "without any configuration" do
        it "returns ActivityNotification::Common.printable_name" do
          expect(test_instance.printable_group_name).to eq(test_instance.printable_name)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._printable_notification_group_name = 'test_printable_name'
          expect(test_instance.printable_group_name).to eq('test_printable_name')
        end

        it "returns specified symbol of field" do
          described_class._printable_notification_group_name = :title
          expect(test_instance.printable_group_name).to eq(test_instance.title)
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            def custom_printable_name
              'test_printable_name'
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._printable_notification_group_name = :custom_printable_name
          expect(test_instance.printable_group_name).to eq('test_printable_name')
        end

        it "returns specified lambda with single target argument" do
          described_class._printable_notification_group_name = ->(target){ 'test_printable_name' }
          expect(test_instance.printable_group_name).to eq('test_printable_name')
        end
      end
    end
  end
end