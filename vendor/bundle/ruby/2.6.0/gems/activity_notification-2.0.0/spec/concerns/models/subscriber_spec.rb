shared_examples_for :subscriber do
  include ActiveJob::TestHelper
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }
  before do
    ActiveJob::Base.queue_adapter = :test
    ActivityNotification::Mailer.deliveries.clear
    expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
  end

  describe "with association" do
    it "has many subscriptions" do
      subscription_1 = create(:subscription, target: test_instance, key: 'subscription_key_1')
      subscription_2 = create(:subscription, target: test_instance, key: 'subscription_key_2', created_at: subscription_1.created_at + 10.second)
      expect(test_instance.subscriptions.count).to                eq(2)
      expect(test_instance.subscriptions.earliest_order.first).to eq(subscription_1)
      expect(test_instance.subscriptions.latest_order.first).to   eq(subscription_2)
      expect(test_instance.subscriptions.latest_order.to_a).to    eq(ActivityNotification::Subscription.filtered_by_target(test_instance).latest_order.to_a)
    end
  end    

  describe "as public class methods" do
    describe ".available_as_subscriber?" do
      it "returns true" do
        expect(described_class.available_as_subscriber?).to be_truthy
      end
    end
  end

  describe "as public instance methods" do
    describe "#find_subscription" do
      before do
        expect(test_instance.subscriptions.to_a).to be_empty
      end

      context "when the cofigured subscription exists" do
        it "returns subscription record" do
          subscription = test_instance.create_subscription(key: 'test_key')
          expect(test_instance.subscriptions.reload.to_a).not_to be_empty
          expect(test_instance.find_subscription('test_key')).to eq(subscription)
        end
      end

      context "when the cofigured subscription does not exist" do
        it "returns nil" do
          expect(test_instance.find_subscription('test_key')).to be_nil
        end
      end
    end

    describe "#find_or_create_subscription" do
      before do
        expect(test_instance.subscriptions.to_a).to be_empty
      end

      context "when the cofigured subscription exists" do
        it "returns subscription record" do
          subscription = test_instance.create_subscription(key: 'test_key')
          expect(test_instance.subscriptions.reload.to_a).not_to be_empty
          expect(test_instance.find_or_create_subscription('test_key')).to eq(subscription)
        end
      end

      context "when the cofigured subscription does not exist" do
        it "returns created subscription record" do
          expect(test_instance.find_or_create_subscription('test_key').target).to eq(test_instance)
        end
      end
    end

    describe "#create_subscription" do
      before do
        expect(test_instance.subscriptions.to_a).to be_empty
      end

      context "without params" do
        it "does not create a new subscription since it is invalid" do
          new_subscription = test_instance.create_subscription
          expect(new_subscription).to                        be_nil
          expect(test_instance.subscriptions.reload.to_a).to be_empty
        end
      end

      context "with only key params" do
        it "creates a new subscription" do
          params = { key: 'key_1' }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to           be_truthy
          expect(new_subscription.subscribing_to_email?).to  be_truthy
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with false as subscribing params" do
        it "creates a new subscription" do
          params = { key: 'key_1', subscribing: false }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to           be_falsey
          expect(new_subscription.subscribing_to_email?).to  be_falsey
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with false as subscribing_to_email params" do
        it "creates a new subscription" do
          params = { key: 'key_1', subscribing_to_email: false }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to           be_truthy
          expect(new_subscription.subscribing_to_email?).to  be_falsey
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with true as subscribing and false as subscribing_to_email params" do
        it "creates a new subscription" do
          params = { key: 'key_1', subscribing: true, subscribing_to_email: false }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to           be_truthy
          expect(new_subscription.subscribing_to_email?).to  be_falsey
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with false as subscribing and true as subscribing_to_email params" do
        it "does not create a new subscription since it is invalid" do
          params = { key: 'key_1', subscribing: false, subscribing_to_email: true }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription).to                        be_nil
          expect(test_instance.subscriptions.reload.to_a).to be_empty
        end
      end



      context "with true as optional_targets params" do
        it "creates a new subscription" do
          params = { key: 'key_1', optional_targets: { subscribing_to_console_output: true } }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to                                     be_truthy
          expect(new_subscription.subscribing_to_optional_target?(:console_output)).to be_truthy
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with false as optional_targets params" do
        it "creates a new subscription" do
          params = { key: 'key_1', optional_targets: { subscribing_to_console_output: false } }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to                                     be_truthy
          expect(new_subscription.subscribing_to_optional_target?(:console_output)).to be_falsey
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with true as subscribing and false as optional_targets params" do
        it "creates a new subscription" do
          params = { key: 'key_1', subscribing: true, optional_targets: { subscribing_to_console_output: false } }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription.subscribing?).to                                     be_truthy
          expect(new_subscription.subscribing_to_optional_target?(:console_output)).to be_falsey
          expect(test_instance.subscriptions.reload.size).to eq(1)
        end
      end

      context "with false as subscribing and true as optional_targets params" do
        it "does not create a new subscription since it is invalid" do
          params = { key: 'key_1', subscribing: false, optional_targets: { subscribing_to_console_output: true } }
          new_subscription = test_instance.create_subscription(params)
          expect(new_subscription).to                        be_nil
          expect(test_instance.subscriptions.reload.to_a).to be_empty
        end
      end
    end

    describe "#subscription_index" do
      context "when the target has no subscriptions" do
        it "returns empty records" do
          expect(test_instance.subscription_index).to be_empty
        end
      end

      context "when the target has subscriptions" do
        before do
          @subscription2 = create(:subscription, target: test_instance, key: 'subscription_key_2')
          @subscription1 = create(:subscription, target: test_instance, key: 'subscription_key_1', created_at: @subscription2.created_at + 10.second)
        end

        context "without any options" do
          it "returns the array of subscriptions" do
            expect(test_instance.subscription_index[0]).to   eq(@subscription1)
            expect(test_instance.subscription_index[1]).to   eq(@subscription2)
            expect(test_instance.subscription_index.size).to eq(2)
          end
        end

        context "with limit" do
          it "returns the same as subscriptions with limit" do
            options = { limit: 1 }
            expect(test_instance.subscription_index(options)[0]).to   eq(@subscription1)
            expect(test_instance.subscription_index(options).size).to eq(1)
          end
        end

        context "with reverse" do
          it "returns the earliest order" do
            options = { reverse: true }
            expect(test_instance.subscription_index(options)[0]).to   eq(@subscription2)
            expect(test_instance.subscription_index(options)[1]).to   eq(@subscription1)
            expect(test_instance.subscription_index(options).size).to eq(2)
          end
        end

        context 'with filtered_by_key options' do
          it "returns filtered notifications only" do
            options = { filtered_by_key: 'subscription_key_2' }
            expect(test_instance.subscription_index(options)[0]).to   eq(@subscription2)
            expect(test_instance.subscription_index(options).size).to eq(1)
          end
        end

        context 'with custom_filter options' do
          it "returns filtered subscriptions only" do
            options = { custom_filter: { key: 'subscription_key_1' } }
            expect(test_instance.subscription_index(options)[0]).to   eq(@subscription1)
            expect(test_instance.subscription_index(options).size).to eq(1)
          end

          it "returns filtered subscriptions only with filter depending on ORM" do
            options =
              case ActivityNotification.config.orm
              when :active_record then { custom_filter: ["subscriptions.key = ?", 'subscription_key_2'] }
              when :mongoid       then { custom_filter: { key: {'$eq': 'subscription_key_2'} } }
              when :dynamoid      then { custom_filter: {'key.begins_with': 'subscription_key_2'} }
              end
            expect(test_instance.subscription_index(options)[0]).to   eq(@subscription2)
            expect(test_instance.subscription_index(options).size).to eq(1)
          end
        end

        if ActivityNotification.config.orm == :active_record
          context 'with with_target options' do
            it "calls with_target" do
              expect(ActivityNotification::Subscription).to receive_message_chain(:with_target)
              test_instance.subscription_index(with_target: true)
            end
          end
        end
      end
    end

    describe "#notification_keys" do
      context "when the target has no notifications" do
        it "returns empty records" do
          expect(test_instance.notification_keys).to be_empty
        end
      end

      context "when the target has notifications" do
        before do
          notification = create(:notification, target: test_instance, key: 'notification_key_2')
          create(:notification, target: test_instance, key: 'notification_key_1', created_at: notification.created_at + 10.second)
          create(:subscription, target: test_instance, key: 'notification_key_1')
        end

        context "without any options" do
          it "returns the array of notification keys" do
            expect(test_instance.notification_keys[0]).to eq('notification_key_1')
            expect(test_instance.notification_keys[1]).to eq('notification_key_2')
            expect(test_instance.notification_keys.size).to eq(2)
          end
        end

        context "with limit" do
          it "returns the same as subscriptions with limit" do
            options = { limit: 1 }
            expect(test_instance.notification_keys(options)[0]).to eq('notification_key_1')
            expect(test_instance.notification_keys(options).size).to eq(1)
          end
        end

        context "with reverse" do
          it "returns the earliest order" do
            options = { reverse: true }
            expect(test_instance.notification_keys(options)[0]).to eq('notification_key_2')
            expect(test_instance.notification_keys(options)[1]).to eq('notification_key_1')
            expect(test_instance.notification_keys(options).size).to eq(2)
          end
        end

        context 'with filter' do
          context 'as :configured' do
            it "returns notification keys of configured subscriptions only" do
              options = { filter: :configured }
              expect(test_instance.notification_keys(options)[0]).to eq('notification_key_1')
              expect(test_instance.notification_keys(options).size).to eq(1)
              options = { filter: 'configured' }
              expect(test_instance.notification_keys(options)[0]).to eq('notification_key_1')
              expect(test_instance.notification_keys(options).size).to eq(1)
            end
          end

          context 'as :unconfigured' do
            it "returns unconfigured notification keys only" do
              options = { filter: :unconfigured }
              expect(test_instance.notification_keys(options)[0]).to eq('notification_key_2')
              expect(test_instance.notification_keys(options).size).to eq(1)
              options = { filter: 'unconfigured' }
              expect(test_instance.notification_keys(options)[0]).to eq('notification_key_2')
              expect(test_instance.notification_keys(options).size).to eq(1)
            end
          end
        end

        context 'with filtered_by_key options' do
          it "returns filtered notifications only" do
            options = { filtered_by_key: 'notification_key_2' }
            expect(test_instance.notification_keys(options)[0]).to eq('notification_key_2')
            expect(test_instance.notification_keys(options).size).to eq(1)
          end
        end

        context 'with custom_filter options' do
          it "returns filtered notifications only" do
            options = { custom_filter: { key: 'notification_key_1' } }
            expect(test_instance.notification_keys(options)[0]).to eq('notification_key_1')
            expect(test_instance.notification_keys(options).size).to eq(1)
          end

          it "returns filtered notifications only with filter depending on ORM" do
            options =
              case ActivityNotification.config.orm
              when :active_record then { custom_filter: ["notifications.key = ?", 'notification_key_2'] }
              when :mongoid       then { custom_filter: { key: {'$eq': 'notification_key_2'} } }
              when :dynamoid      then { custom_filter: {'key.begins_with': 'notification_key_2'} }
              end
            expect(test_instance.notification_keys(options)[0]).to eq('notification_key_2')
            expect(test_instance.notification_keys(options).size).to eq(1)
          end
        end
      end
    end

    # Function test for subscriptions

    describe "#receive_notification_of" do
      before do
        @test_key = 'test_key'
        Comment.acts_as_notifiable described_class.to_s.underscore.pluralize.to_sym, targets: [], email_allowed: true
        @notifiable = create(:comment)
        expect(@notifiable.notification_email_allowed?(test_instance, @test_key)).to be_truthy
      end

      context "subscribing to notification" do
        before do
          test_instance.create_subscription(key: @test_key)
          expect(test_instance.subscribes_to_notification?(@test_key)).to be_truthy
        end

        it "returns created notification" do
          notification = test_instance.receive_notification_of(@notifiable, key: @test_key)
          expect(notification).not_to be_nil
          expect(notification.target).to eq(test_instance)
        end
  
        it "creates notification records" do
          test_instance.receive_notification_of(@notifiable, key: @test_key)
          expect(test_instance.notifications.unopened_only.count).to eq(1)
        end
      end

      context "subscribing to notification email" do
        before do
          test_instance.create_subscription(key: @test_key)
          expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_truthy
        end

        context "as default" do
          it "sends notification email later" do
            expect {
              perform_enqueued_jobs do
                test_instance.receive_notification_of(@notifiable, key: @test_key)
              end
            }.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
            expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          end
  
          it "sends notification email with active job queue" do
            expect {
              test_instance.receive_notification_of(@notifiable, key: @test_key)
            }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
          end
        end

        context "with send_later false" do
          it "sends notification email now" do
            test_instance.receive_notification_of(@notifiable, key: @test_key, send_later: false)
            expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          end
        end
      end

      context "unsubscribed to notification" do
        before do
          test_instance.create_subscription(key: @test_key, subscribing: false)
          expect(test_instance.subscribes_to_notification?(@test_key)).to be_falsey
        end

        it "returns nil" do
          notification = test_instance.receive_notification_of(@notifiable, key: @test_key)
          expect(notification).to be_nil
        end
  
        it "does not create notification records" do
          test_instance.receive_notification_of(@notifiable, key: @test_key)
          expect(test_instance.notifications.unopened_only.count).to eq(0)
        end
      end

      context "unsubscribed to notification email" do
        before do
          test_instance.create_subscription(key: @test_key, subscribing: true, subscribing_to_email: false)
          expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_falsey
        end

        context "as default" do
          it "does not send notification email later" do
            expect {
              perform_enqueued_jobs do
                test_instance.receive_notification_of(@notifiable, key: @test_key)
              end
            }.to change { ActivityNotification::Mailer.deliveries.size }.by(0)
            expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
          end
  
          it "does not send notification email with active job queue" do
            expect {
              test_instance.receive_notification_of(@notifiable, key: @test_key)
            }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(0)
          end
        end

        context "with send_later false" do
          it "does not send notification email now" do
            test_instance.receive_notification_of(@notifiable, key: @test_key, send_later: false)
            expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
          end
        end
      end
    end

    describe "#subscribes_to_notification?" do
      before do
        @test_key = 'test_key'
      end

      context "when the subscription is not enabled for the target" do
        it "returns true" do
          described_class._notification_subscription_allowed = false
          expect(test_instance.subscribes_to_notification?(@test_key)).to be_truthy
        end
      end

      context "when the subscription is enabled for the target" do
        before do
          described_class._notification_subscription_allowed = true
        end

        context "without configured subscpriotion" do
          context "without subscribe_as_default argument" do
            context "with true as ActivityNotification.config.subscribe_as_default" do
              it "returns true" do
                subscribe_as_default = ActivityNotification.config.subscribe_as_default
                ActivityNotification.config.subscribe_as_default = true
                expect(test_instance.subscribes_to_notification?(@test_key)).to be_truthy
                ActivityNotification.config.subscribe_as_default = subscribe_as_default
              end
            end

            context "with false as ActivityNotification.config.subscribe_as_default" do
              it "returns false" do
                subscribe_as_default = ActivityNotification.config.subscribe_as_default
                ActivityNotification.config.subscribe_as_default = false
                expect(test_instance.subscribes_to_notification?(@test_key)).to be_falsey
                ActivityNotification.config.subscribe_as_default = subscribe_as_default
              end
            end
          end
        end

        context "with configured subscpriotion" do
          context "subscribing to notification" do
            it "returns true" do
              subscription = test_instance.create_subscription(key: @test_key)
              expect(subscription.subscribing?).to be_truthy
              expect(test_instance.subscribes_to_notification?(@test_key)).to be_truthy
            end
          end

          context "unsubscribed to notification" do
            it "returns false" do
              subscription = test_instance.create_subscription(key: @test_key, subscribing: false)
              expect(subscription.subscribing?).to be_falsey
              expect(test_instance.subscribes_to_notification?(@test_key)).to be_falsey
            end
          end
        end
      end
    end

    describe "#subscribes_to_notification_email?" do
      before do
        @test_key = 'test_key'
      end

      context "when the subscription is not enabled for the target" do
        it "returns true" do
          described_class._notification_subscription_allowed = false
          expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_truthy
        end
      end

      context "when the subscription is enabled for the target" do
        before do
          described_class._notification_subscription_allowed = true
        end

        context "without configured subscpriotion" do
          context "without subscribe_as_default argument" do
            context "with true as ActivityNotification.config.subscribe_as_default" do
              it "returns true" do
                subscribe_as_default = ActivityNotification.config.subscribe_as_default
                ActivityNotification.config.subscribe_as_default = true
                expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_truthy
                ActivityNotification.config.subscribe_as_default = subscribe_as_default
              end
            end

            context "with false as ActivityNotification.config.subscribe_as_default" do
              it "returns false" do
                subscribe_as_default = ActivityNotification.config.subscribe_as_default
                ActivityNotification.config.subscribe_as_default = false
                expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_falsey
                ActivityNotification.config.subscribe_as_default = subscribe_as_default
              end
            end
          end
        end

        context "with configured subscpriotion" do
          context "subscribing to notification email" do
            it "returns true" do
              subscription = test_instance.create_subscription(key: @test_key)
              expect(subscription.subscribing_to_email?).to be_truthy
              expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_truthy
            end
          end

          context "unsubscribed to notification email" do
            it "returns false" do
              subscription = test_instance.create_subscription(key: @test_key, subscribing: true, subscribing_to_email: false)
              expect(subscription.subscribing_to_email?).to be_falsey
              expect(test_instance.subscribes_to_notification_email?(@test_key)).to be_falsey
            end
          end
        end
      end
    end

    describe "#subscribes_to_optional_target?" do
      before do
        @test_key             = 'test_key'
        @optional_target_name = :console_output
      end

      context "when the subscription is not enabled for the target" do
        it "returns true" do
          described_class._notification_subscription_allowed = false
          expect(test_instance.subscribes_to_optional_target?(@test_key, @optional_target_name)).to be_truthy
        end
      end

      context "when the subscription is enabled for the target" do
        before do
          described_class._notification_subscription_allowed = true
        end

        context "without configured subscpriotion" do
          context "without subscribe_as_default argument" do
            context "with true as ActivityNotification.config.subscribe_as_default" do
              it "returns true" do
                subscribe_as_default = ActivityNotification.config.subscribe_as_default
                ActivityNotification.config.subscribe_as_default = true
                expect(test_instance.subscribes_to_optional_target?(@test_key, @optional_target_name)).to be_truthy
                ActivityNotification.config.subscribe_as_default = subscribe_as_default
              end
            end

            context "with false as ActivityNotification.config.subscribe_as_default" do
              it "returns false" do
                subscribe_as_default = ActivityNotification.config.subscribe_as_default
                ActivityNotification.config.subscribe_as_default = false
                expect(test_instance.subscribes_to_optional_target?(@test_key, @optional_target_name)).to be_falsey
                ActivityNotification.config.subscribe_as_default = subscribe_as_default
              end
            end
          end
        end

        context "with configured subscpriotion" do
          context "subscribing to the specified optional target" do
            it "returns true" do
              subscription = test_instance.create_subscription(key: @test_key, optional_targets: { ActivityNotification::Subscription.to_optional_target_key(@optional_target_name) => true })
              expect(subscription.subscribing_to_optional_target?(@optional_target_name)).to be_truthy
              expect(test_instance.subscribes_to_optional_target?(@test_key, @optional_target_name)).to be_truthy
            end
          end

          context "unsubscribed to the specified optional target" do
            it "returns false" do
              subscription = test_instance.create_subscription(key: @test_key, subscribing: true, optional_targets: { ActivityNotification::Subscription.to_optional_target_key(@optional_target_name) => false })
              expect(subscription.subscribing_to_optional_target?(@optional_target_name)).to be_falsey
              expect(test_instance.subscribes_to_optional_target?(@test_key, @optional_target_name)).to be_falsey
            end
          end
        end
      end
    end

  end
end