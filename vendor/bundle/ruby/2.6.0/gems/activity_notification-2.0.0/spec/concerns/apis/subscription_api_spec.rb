shared_examples_for :subscription_api do
  include ActiveJob::TestHelper
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }

  describe "as public class methods" do
    describe ".to_optional_target_key" do
      it "returns optional target key" do
        expect(described_class.to_optional_target_key(:console_output)).to eq(:subscribing_to_console_output)
      end
    end

    describe ".to_optional_target_subscribed_at_key" do
      it "returns optional target subscribed_at key" do
        expect(described_class.to_optional_target_subscribed_at_key(:console_output)).to eq(:subscribed_to_console_output_at)
      end
    end

    describe ".to_optional_target_unsubscribed_at_key" do
      it "returns optional target unsubscribed_at key" do
        expect(described_class.to_optional_target_unsubscribed_at_key(:console_output)).to eq(:unsubscribed_to_console_output_at)
      end
    end
  end

  describe "as public instance methods" do
    describe "#subscribe" do
      before do
        test_instance.unsubscribe
      end

      it "returns if successfully updated subscription instance" do
        expect(test_instance.subscribe).to be_truthy
      end

      context "as default" do
        it "subscribe with current time" do
          expect(test_instance.subscribing?).to                   eq(false)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.subscribe
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(true)
          expect(test_instance.subscribed_at).to                  eq(Time.current)
          expect(test_instance.subscribed_to_email_at).to         eq(Time.current)
          Timecop.return
        end
      end

      context "with subscribed_at option" do
        it "subscribe with specified time" do
          expect(test_instance.subscribing?).to                   eq(false)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          subscribed_at = Time.current - 1.months
          test_instance.subscribe(subscribed_at: subscribed_at)
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(true)
          expect(test_instance.subscribed_at.to_i).to             eq(subscribed_at.to_i)
          expect(test_instance.subscribed_to_email_at.to_i).to    eq(subscribed_at.to_i)
        end
      end

      context "with false as with_email_subscription" do
        it "does not subscribe to email" do
          expect(test_instance.subscribing?).to                   eq(false)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          test_instance.subscribe(with_email_subscription: false)
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(false)
        end
      end

      context "with optional targets" do
        it "also subscribes to optional targets" do
          test_instance.unsubscribe_to_optional_target(:console_output)
          expect(test_instance.subscribing?).to                                     eq(false)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to eq(false)
          test_instance.subscribe
          expect(test_instance.subscribing?).to                                     eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to eq(true)
        end
      end

      context "with false as with_optional_targets" do
        it "does not subscribe to optional targets" do
          test_instance.unsubscribe_to_optional_target(:console_output)
          expect(test_instance.subscribing?).to                                     eq(false)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to eq(false)
          test_instance.subscribe(with_optional_targets: false)
          expect(test_instance.subscribing?).to                                     eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to eq(false)
        end
      end
    end

    describe "#unsubscribe" do
      it "returns if successfully updated subscription instance" do
        expect(test_instance.subscribe).to be_truthy
      end

      context "as default" do
        it "unsubscribe with current time" do
          expect(test_instance.subscribing?).to                     eq(true)
          expect(test_instance.subscribing_to_email?).to            eq(true)
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.unsubscribe
          expect(test_instance.subscribing?).to                     eq(false)
          expect(test_instance.subscribing_to_email?).to            eq(false)
          expect(test_instance.unsubscribed_at).to                  eq(Time.current)
          expect(test_instance.unsubscribed_to_email_at).to         eq(Time.current)
          Timecop.return
        end
      end

      context "with unsubscribed_at option" do
        it "unsubscribe with specified time" do
          expect(test_instance.subscribing?).to                     eq(true)
          expect(test_instance.subscribing_to_email?).to            eq(true)
          unsubscribed_at = Time.current - 1.months
          test_instance.unsubscribe(unsubscribed_at: unsubscribed_at)
          expect(test_instance.subscribing?).to                     eq(false)
          expect(test_instance.subscribing_to_email?).to            eq(false)
          expect(test_instance.unsubscribed_at.to_i).to             eq(unsubscribed_at.to_i)
          expect(test_instance.unsubscribed_to_email_at.to_i).to    eq(unsubscribed_at.to_i)
        end
      end
    end

    describe "#subscribe_to_email" do
      before do
        test_instance.unsubscribe_to_email
      end

      context "for subscribing instance" do
        it "returns true as successfully updated subscription instance" do
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          expect(test_instance.subscribe_to_email).to be_truthy
        end
      end

      context "for not subscribing instance" do
        it "returns false as failure to update subscription instance" do
          test_instance.unsubscribe
          expect(test_instance.subscribing?).to                   eq(false)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          expect(test_instance.subscribe_to_email).to be_falsey
        end
      end

      context "as default" do
        it "subscribe_to_email with current time" do
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.subscribe_to_email
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(true)
          expect(test_instance.subscribed_to_email_at).to         eq(Time.current)
          Timecop.return
        end
      end

      context "with subscribed_to_email_at option" do
        it "subscribe with specified time" do
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(false)
          subscribed_to_email_at = Time.current - 1.months
          test_instance.subscribe_to_email(subscribed_to_email_at: subscribed_to_email_at)
          expect(test_instance.subscribing?).to                   eq(true)
          expect(test_instance.subscribing_to_email?).to          eq(true)
          expect(test_instance.subscribed_to_email_at.to_i).to    eq(subscribed_to_email_at.to_i)
        end
      end
    end

    describe "#unsubscribe_to_email" do
      it "returns if successfully updated subscription instance" do
        expect(test_instance.unsubscribe_to_email).to be_truthy
      end

      context "as default" do
        it "unsubscribe_to_email with current time" do
          expect(test_instance.subscribing?).to                     eq(true)
          expect(test_instance.subscribing_to_email?).to            eq(true)
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.unsubscribe_to_email
          expect(test_instance.subscribing?).to                     eq(true)
          expect(test_instance.subscribing_to_email?).to            eq(false)
          expect(test_instance.unsubscribed_to_email_at).to         eq(Time.current)
          Timecop.return
        end
      end

      context "with unsubscribed_to_email_at option" do
        it "unsubscribe with specified time" do
          expect(test_instance.subscribing?).to                     eq(true)
          expect(test_instance.subscribing_to_email?).to            eq(true)
          unsubscribed_to_email_at = Time.current - 1.months
          test_instance.unsubscribe_to_email(unsubscribed_to_email_at: unsubscribed_to_email_at)
          expect(test_instance.subscribing?).to                     eq(true)
          expect(test_instance.subscribing_to_email?).to            eq(false)
          expect(test_instance.unsubscribed_to_email_at.to_i).to    eq(unsubscribed_to_email_at.to_i)
        end
      end
    end

    describe "#subscribing_to_optional_target?" do
      before do
        test_instance.update(optional_targets: {})
      end

      context "without configured optional target subscpriotion" do
        context "without subscribe_as_default argument" do
          context "with true as ActivityNotification.config.subscribe_as_default" do
            it "returns true" do
              subscribe_as_default = ActivityNotification.config.subscribe_as_default
              ActivityNotification.config.subscribe_as_default = true
              expect(test_instance.subscribing_to_optional_target?(:console_output)).to be_truthy
              ActivityNotification.config.subscribe_as_default = subscribe_as_default
            end
          end

          context "with false as ActivityNotification.config.subscribe_as_default" do
            it "returns false" do
              subscribe_as_default = ActivityNotification.config.subscribe_as_default
              ActivityNotification.config.subscribe_as_default = false
              expect(test_instance.subscribing_to_optional_target?(:console_output)).to be_falsey
              ActivityNotification.config.subscribe_as_default = subscribe_as_default
            end
          end
        end
      end

      context "with configured subscpriotion" do
        context "subscribing to optional target" do
          it "returns true" do
            test_instance.subscribe_to_optional_target(:console_output)
            expect(test_instance.subscribing_to_optional_target?(:console_output)).to be_truthy
          end
        end

        context "unsubscribed to optional target" do
          it "returns false" do
            test_instance.unsubscribe_to_optional_target(:console_output)
            expect(test_instance.subscribing_to_optional_target?(:console_output)).to be_falsey
          end
        end
      end
    end

    describe "#subscribe_to_optional_target" do
      before do
        test_instance.unsubscribe_to_optional_target(:console_output)
      end

      context "for subscribing instance" do
        it "returns true as successfully updated subscription instance" do
          expect(test_instance.subscribing?).to                                         eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to     eq(false)
          expect(test_instance.subscribe_to_optional_target(:console_output)).to        be_truthy
        end
      end

      context "for not subscribing instance" do
        it "returns false as failure to update subscription instance" do
          test_instance.unsubscribe
          expect(test_instance.subscribing?).to                                         eq(false)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to     eq(false)
          expect(test_instance.subscribe_to_optional_target(:console_output)).to        be_falsey
        end
      end

      context "as default" do
        it "subscribe_to_optional_target with current time" do
          expect(test_instance.subscribing?).to                                         eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to     eq(false)
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.subscribe_to_optional_target(:console_output)
          expect(test_instance.subscribing?).to                                         eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to     eq(true)
          expect(test_instance.optional_targets[:subscribed_to_console_output_at]).to   eq(ActivityNotification::Subscription.convert_time_as_hash(Time.current))
          Timecop.return
        end
      end

      context "with subscribed_at option" do
        it "subscribe with specified time" do
          expect(test_instance.subscribing?).to                                            eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to        eq(false)
          subscribed_at = Time.current - 1.months
          test_instance.subscribe_to_optional_target(:console_output, subscribed_at: subscribed_at)
          expect(test_instance.subscribing?).to                                            eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to        eq(true)
          expect(test_instance.optional_targets[:subscribed_to_console_output_at].to_i).to eq(subscribed_at.to_i)
        end
      end
    end

    describe "#unsubscribe_to_optional_target" do
      it "returns if successfully updated subscription instance" do
        expect(test_instance.unsubscribe_to_optional_target(:console_output)).to be_truthy
      end

      context "as default" do
        it "unsubscribe_to_optional_target with current time" do
          expect(test_instance.subscribing?).to                                         eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to     eq(true)
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.unsubscribe_to_optional_target(:console_output)
          expect(test_instance.subscribing?).to                                         eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to     eq(false)
          expect(test_instance.optional_targets[:unsubscribed_to_console_output_at]).to eq(ActivityNotification::Subscription.convert_time_as_hash(Time.current))
          Timecop.return
        end
      end

      context "with unsubscribed_at option" do
        it "unsubscribe with specified time" do
          expect(test_instance.subscribing?).to                                              eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to          eq(true)
          unsubscribed_at = Time.current - 1.months
          test_instance.unsubscribe_to_optional_target(:console_output, unsubscribed_at: unsubscribed_at)
          expect(test_instance.subscribing?).to                                              eq(true)
          expect(test_instance.subscribing_to_optional_target?(:console_output)).to          eq(false)
          expect(test_instance.optional_targets[:unsubscribed_to_console_output_at].to_i).to eq(unsubscribed_at.to_i)
        end
      end
    end

  end
end