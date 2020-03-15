describe ActivityNotification::OptionalTarget::Base do
  let(:test_instance) {
    ActivityNotification::OptionalTarget::Base.new(skip_initializing_target: true)
  }

  describe "as public instance methods" do
    describe "#to_optional_target_name" do
      it "is return demodulized symbol class name" do
        expect(test_instance.to_optional_target_name).to eq(:base)
      end
    end

    describe "#initialize_target" do
      it "raises NotImplementedError" do
        expect { test_instance.initialize_target }
          .to raise_error(NotImplementedError, /You have to implement ActivityNotification::OptionalTarget::Base#initialize_target/)
      end
    end

    describe "#notify" do
      it "raises NotImplementedError" do
        expect { test_instance.notify(create(:notification)) }
          .to raise_error(NotImplementedError, /You have to implement ActivityNotification::OptionalTarget::Base#notify/)
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
