shared_examples_for :target do
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }
  let(:test_notifiable) { create(:dummy_notifiable) }

  describe "with association" do
    it "has many notifications" do
      notification_1 = create(:notification, target: test_instance)
      notification_2 = create(:notification, target: test_instance, created_at: notification_1.created_at + 10.second)
      expect(test_instance.notifications.count).to    eq(2)
      expect(test_instance.notifications.earliest).to eq(notification_1)
      expect(test_instance.notifications.latest).to   eq(notification_2)
      expect(test_instance.notifications.to_a).to     eq(ActivityNotification::Notification.filtered_by_target(test_instance).to_a)
    end
  end    

  describe "as public class methods" do
    describe ".available_as_target?" do
      it "returns true" do
        expect(described_class.available_as_target?).to be_truthy
      end
    end

    describe ".set_target_class_defaults" do
      it "set parameter fields as default" do
        described_class.set_target_class_defaults
        expect(described_class._notification_email).to                    eq(nil)
        expect(described_class._notification_email_allowed).to            eq(ActivityNotification.config.email_enabled)
        expect(described_class._batch_notification_email_allowed).to      eq(ActivityNotification.config.email_enabled)
        expect(described_class._notification_subscription_allowed).to     eq(ActivityNotification.config.subscription_enabled)
        expect(described_class._notification_action_cable_allowed).to     eq(ActivityNotification.config.action_cable_enabled)
        expect(described_class._notification_action_cable_with_devise).to eq(ActivityNotification.config.action_cable_with_devise)
        expect(described_class._notification_devise_resource).to          be_a_kind_of(Proc)
        expect(described_class._notification_current_devise_target).to    be_a_kind_of(Proc)
        expect(described_class._printable_notification_target_name).to    eq(:printable_name)
      end
    end    

    describe ".notification_index_map" do
      it "returns notifications of this target type group by target" do
        ActivityNotification::Notification.delete_all
        target_1 = create(test_class_name)
        target_2 = create(test_class_name)
        notification_1 = create(:notification, target: target_1)
        notification_2 = create(:notification, target: target_1)
        notification_3 = create(:notification, target: target_1)
        notification_4 = create(:notification, target: target_2)
        notification_5 = create(:notification, target: target_2)
        notification_6 = create(:notification, target: test_notifiable)

        index_map = described_class.notification_index_map
        expect(index_map.size).to eq(2)
        expect(index_map[target_1].size).to eq(3)
        expect(described_class.notification_index_map[target_2].size).to eq(2)
      end

      context "with :filtered_by_status" do
        context "as :opened" do
          it "returns opened notifications of this target type group by target" do
            ActivityNotification::Notification.delete_all
            target_1 = create(test_class_name)
            target_2 = create(test_class_name)
            target_3 = create(test_class_name)
            notification_1 = create(:notification, target: target_1)
            notification_2 = create(:notification, target: target_1)
            notification_2.open!
            notification_3 = create(:notification, target: target_1)
            notification_3.open!
            notification_4 = create(:notification, target: target_2)
            notification_5 = create(:notification, target: target_2)
            notification_5.open!
            notification_6 = create(:notification, target: target_3)
            notification_7 = create(:notification, target: test_notifiable)
    
            index_map = described_class.notification_index_map(filtered_by_status: :opened)
            expect(index_map.size).to eq(2)
            expect(index_map[target_1].size).to eq(2)
            expect(index_map[target_2].size).to eq(1)
            expect(index_map.has_key?(target_3)).to be_falsey
          end
        end

        context "as :unopened" do
          it "returns unopened notifications of this target type group by target" do
            ActivityNotification::Notification.delete_all
            target_1 = create(test_class_name)
            target_2 = create(test_class_name)
            target_3 = create(test_class_name)
            notification_1 = create(:notification, target: target_1)
            notification_2 = create(:notification, target: target_1)
            notification_3 = create(:notification, target: target_1)
            notification_3.open!
            notification_4 = create(:notification, target: target_2)
            notification_5 = create(:notification, target: target_2)
            notification_5.open!
            notification_6 = create(:notification, target: target_3)
            notification_6.open!
            notification_7 = create(:notification, target: test_notifiable)
    
            index_map = described_class.notification_index_map(filtered_by_status: :unopened)
            expect(index_map.size).to eq(2)
            expect(index_map[target_1].size).to eq(2)
            expect(index_map[target_2].size).to eq(1)
            expect(index_map.has_key?(target_3)).to be_falsey
          end
        end
      end

      context "with :as_latest_group_member" do
        before do
          ActivityNotification::Notification.delete_all
          @target_1 = create(test_class_name)
          @target_2 = create(test_class_name)
          @target_3 = create(test_class_name)
          notification_1  = create(:notification, target: @target_1)
          @notification_2 = create(:notification, target: @target_1, created_at: notification_1.created_at + 10.second)
          notification_3  = create(:notification, target: @target_1, group_owner: @notification_2, created_at: notification_1.created_at + 20.second)
          @notification_4 = create(:notification, target: @target_1, group_owner: @notification_2, created_at: notification_1.created_at + 30.second)
          notification_5  = create(:notification, target: @target_2, created_at: notification_1.created_at + 40.second)
          notification_6  = create(:notification, target: @target_2, created_at: notification_1.created_at + 50.second)
          notification_6.open!
          notification_7  = create(:notification, target: @target_3, created_at: notification_1.created_at + 60.second)
          notification_7.open!
          notification_8  = create(:notification, target: test_notifiable, created_at: notification_1.created_at + 70.second)
        end

        context "as default" do
          it "returns earliest group members" do
            index_map = described_class.notification_index_map(filtered_by_status: :unopened)
            expect(index_map.size).to eq(2)
            expect(index_map[@target_1].size).to eq(2)
            expect(index_map[@target_1].first).to eq(@notification_2)
            expect(index_map[@target_2].size).to eq(1)
            expect(index_map.has_key?(@target_3)).to be_falsey
          end
        end

        context "as true" do
          it "returns latest group members" do
            index_map = described_class.notification_index_map(filtered_by_status: :unopened, as_latest_group_member: true)
            expect(index_map.size).to eq(2)
            expect(index_map[@target_1].size).to eq(2)
            expect(index_map[@target_1].first).to eq(@notification_4)
            expect(index_map[@target_2].size).to eq(1)
            expect(index_map.has_key?(@target_3)).to be_falsey
          end
        end
      end
    end

    describe ".send_batch_unopened_notification_email" do
      it "sends batch notification email to this type targets with unopened notifications" do
        ActivityNotification::Notification.delete_all
        target_1 = create(test_class_name)
        target_2 = create(test_class_name)
        target_3 = create(test_class_name)
        notification_1 = create(:notification, target: target_1)
        notification_2 = create(:notification, target: target_1)
        notification_3 = create(:notification, target: target_1)
        notification_3.open!
        notification_4 = create(:notification, target: target_2)
        notification_5 = create(:notification, target: target_2)
        notification_5.open!
        notification_6 = create(:notification, target: target_3)
        notification_6.open!
        notification_7 = create(:notification, target: test_notifiable)

        expect(ActivityNotification::Notification).to receive(:send_batch_notification_email).at_least(:once)
        sent_email_map = described_class.send_batch_unopened_notification_email
        expect(sent_email_map.size).to eq(2)
        expect(sent_email_map.has_key?(target_1)).to be_truthy
        expect(sent_email_map.has_key?(target_2)).to be_truthy
        expect(sent_email_map.has_key?(target_3)).to be_falsey
      end
    end

    describe "subscription_enabled?" do
      context "with true as _notification_subscription_allowed" do
        it "returns true" do
          described_class._notification_subscription_allowed = true
          expect(described_class.subscription_enabled?).to eq(true)
        end
      end

      context "with false as _notification_subscription_allowed" do
        it "returns false" do
          described_class._notification_subscription_allowed = false
          expect(described_class.subscription_enabled?).to eq(false)
        end
      end

      context "with lambda configuration as _notification_subscription_allowed" do
        it "returns true (even if configured lambda function returns false)" do
          described_class._notification_subscription_allowed = ->(target, key){ false }
          expect(described_class.subscription_enabled?).to eq(true)
        end
      end
    end
  end

  describe "as public instance methods" do
    before do
      ActivityNotification::Notification.delete_all
      described_class.set_target_class_defaults
    end

    describe "#mailer_to" do
      context "without any configuration" do
        it "returns nil" do
          expect(test_instance.mailer_to).to be_nil
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_email = 'test@example.com'
          expect(test_instance.mailer_to).to eq('test@example.com')
        end

        it "returns specified symbol of field" do
          described_class._notification_email = :email
          expect(test_instance.mailer_to).to eq(test_instance.email)
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            def custom_notification_email
              'test@example.com'
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_email = :custom_notification_email
          expect(test_instance.mailer_to).to eq('test@example.com')
        end

        it "returns specified lambda with single target argument" do
          described_class._notification_email = ->(target){ 'test@example.com' }
          expect(test_instance.mailer_to).to eq('test@example.com')
        end
      end
    end

    describe "#notification_email_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.email_enabled" do
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key'))
            .to eq(ActivityNotification.config.email_enabled)
        end

        it "returns false as default" do
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key')).to be_falsey
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_email_allowed = true
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol without argument" do
          module AdditionalMethods
            def custom_notification_email_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_email_allowed = :custom_notification_email_allowed?
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol with notifiable
         and key arguments" do
          module AdditionalMethods
            def custom_notification_email_allowed?(notifiable, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_email_allowed = :custom_notification_email_allowed?
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with single target argument" do
          described_class._notification_email_allowed = ->(target){ true }
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with target, notifiable and key arguments" do
          described_class._notification_email_allowed = ->(target, notifiable, key){ true }
          expect(test_instance.notification_email_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end
      end
    end

    describe "#batch_notification_email_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.email_enabled" do
          expect(test_instance.batch_notification_email_allowed?('dummy_key'))
            .to eq(ActivityNotification.config.email_enabled)
        end

        it "returns false as default" do
          expect(test_instance.batch_notification_email_allowed?('dummy_key')).to be_falsey
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._batch_notification_email_allowed = true
          expect(test_instance.batch_notification_email_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified symbol without argument" do
          module AdditionalMethods
            def custom_batch_notification_email_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._batch_notification_email_allowed = :custom_batch_notification_email_allowed?
          expect(test_instance.batch_notification_email_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified symbol with target and key arguments" do
          module AdditionalMethods
            def custom_batch_notification_email_allowed?(key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._batch_notification_email_allowed = :custom_batch_notification_email_allowed?
          expect(test_instance.batch_notification_email_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified lambda with single target argument" do
          described_class._batch_notification_email_allowed = ->(target){ true }
          expect(test_instance.batch_notification_email_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified lambda with target and key arguments" do
          described_class._batch_notification_email_allowed = ->(target, key){ true }
          expect(test_instance.batch_notification_email_allowed?('dummy_key')).to eq(true)
        end
      end
    end

    describe "#subscription_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.subscription_enabled" do
          expect(test_instance.subscription_allowed?('dummy_key'))
            .to eq(ActivityNotification.config.subscription_enabled)
        end

        it "returns false as default" do
          expect(test_instance.subscription_allowed?('dummy_key')).to be_falsey
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_subscription_allowed = true
          expect(test_instance.subscription_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified symbol without argument" do
          module AdditionalMethods
            def custom_subscription_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_subscription_allowed = :custom_subscription_allowed?
          expect(test_instance.subscription_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_subscription_allowed?(key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_subscription_allowed = :custom_subscription_allowed?
          expect(test_instance.subscription_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified lambda with single target argument" do
          described_class._notification_subscription_allowed = ->(target){ true }
          expect(test_instance.subscription_allowed?('dummy_key')).to eq(true)
        end

        it "returns specified lambda with target and key arguments" do
          described_class._notification_subscription_allowed = ->(target, key){ true }
          expect(test_instance.subscription_allowed?('dummy_key')).to eq(true)
        end
      end
    end

    describe "#notification_action_cable_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.action_cable_enabled without arguments" do
          expect(test_instance.notification_action_cable_allowed?)
            .to eq(ActivityNotification.config.action_cable_enabled)
        end

        it "returns ActivityNotification.config.action_cable_enabled with arguments" do
          expect(test_instance.notification_action_cable_allowed?(test_notifiable, 'dummy_key'))
            .to eq(ActivityNotification.config.action_cable_enabled)
        end

        it "returns false as default" do
          expect(test_instance.notification_action_cable_allowed?).to be_falsey
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_action_cable_allowed = true
          expect(test_instance.notification_action_cable_allowed?).to eq(true)
        end

        it "returns specified symbol without argument" do
          module AdditionalMethods
            def custom_notification_action_cable_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_action_cable_allowed = :custom_notification_action_cable_allowed?
          expect(test_instance.notification_action_cable_allowed?).to eq(true)
        end

        it "returns specified symbol with notifiable and key arguments" do
          module AdditionalMethods
            def custom_notification_action_cable_allowed?(notifiable, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_action_cable_allowed = :custom_notification_action_cable_allowed?
          expect(test_instance.notification_action_cable_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with single target argument" do
          described_class._notification_action_cable_allowed = ->(target){ true }
          expect(test_instance.notification_action_cable_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with target, notifiable and key arguments" do
          described_class._notification_action_cable_allowed = ->(target, notifiable, key){ true }
          expect(test_instance.notification_action_cable_allowed?(test_notifiable, 'dummy_key')).to eq(true)
        end
      end
    end

    describe "#notification_action_cable_with_devise?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.action_cable_with_devise without arguments" do
          expect(test_instance.notification_action_cable_with_devise?)
            .to eq(ActivityNotification.config.action_cable_with_devise)
        end

        it "returns false as default" do
          expect(test_instance.notification_action_cable_with_devise?).to be_falsey
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_action_cable_with_devise = true
          expect(test_instance.notification_action_cable_with_devise?).to eq(true)
        end

        it "returns specified symbol without argument" do
          module AdditionalMethods
            def custom_notification_action_cable_with_devise?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_action_cable_with_devise = :custom_notification_action_cable_with_devise?
          expect(test_instance.notification_action_cable_with_devise?).to eq(true)
        end

        it "returns specified lambda with single target argument" do
          described_class._notification_action_cable_with_devise = ->(target){ true }
          expect(test_instance.notification_action_cable_with_devise?).to eq(true)
        end
      end
    end

    if Rails::VERSION::MAJOR >= 5
      describe "#notification_action_cable_channel_class_name" do
        context "when custom_notification_action_cable_with_devise? returns true" do
          it "returns ActivityNotification::NotificationWithDeviseChannel" do
            described_class._notification_action_cable_with_devise = true
            expect(test_instance.notification_action_cable_channel_class_name).to eq(ActivityNotification::NotificationWithDeviseChannel.name)
          end
        end

        context "when custom_notification_action_cable_with_devise? returns false" do
          it "returns ActivityNotification::NotificationChannel" do
            described_class._notification_action_cable_with_devise = false
            expect(test_instance.notification_action_cable_channel_class_name).to eq(ActivityNotification::NotificationChannel.name)
          end
        end
      end
    end

    describe "#authenticated_with_devise?" do
      context "without any configuration" do
        context "when the current devise resource and called target are different class instance" do
          it "raises TypeError" do
            expect { test_instance.authenticated_with_devise?(test_notifiable) }
              .to raise_error(TypeError, /Different type of .+ has been passed to .+ You have to override .+ /)
          end
        end
  
        context "when the current devise resource equals called target" do
          it "returns true" do
            expect(test_instance.authenticated_with_devise?(test_instance)).to be_truthy
          end
        end
  
        context "when the current devise resource does not equal called target" do
          it "returns false" do
            expect(test_instance.authenticated_with_devise?(create(test_class_name))).to be_falsey
          end
        end
      end

      context "configured with a field" do
        context "when the current devise resource and called target are different class instance" do
          it "raises TypeError" do
            described_class._notification_devise_resource = test_notifiable
            expect { test_instance.authenticated_with_devise?(test_instance) }
              .to raise_error(TypeError, /Different type of .+ has been passed to .+ You have to override .+ /)
          end
        end
  
        context "when the current devise resource equals called target" do
          it "returns true" do
            described_class._notification_devise_resource = test_notifiable
            expect(test_instance.authenticated_with_devise?(test_notifiable)).to be_truthy
          end
        end
  
        context "when the current devise resource does not equal called target" do
          it "returns false" do
            described_class._notification_devise_resource = test_instance
            expect(test_instance.authenticated_with_devise?(create(test_class_name))).to be_falsey
          end
        end
      end
    end

    describe "#printable_target_name" do
      context "without any configuration" do
        it "returns ActivityNotification::Common.printable_name" do
          expect(test_instance.printable_target_name).to eq(test_instance.printable_name)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._printable_notification_target_name = 'test_printable_name'
          expect(test_instance.printable_target_name).to eq('test_printable_name')
        end

        it "returns specified symbol of field" do
          described_class._printable_notification_target_name = :name
          expect(test_instance.printable_target_name).to eq(test_instance.name)
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            def custom_printable_name
              'test_printable_name'
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._printable_notification_target_name = :custom_printable_name
          expect(test_instance.printable_target_name).to eq('test_printable_name')
        end

        it "returns specified lambda with single target argument" do
          described_class._printable_notification_target_name = ->(target){ 'test_printable_name' }
          expect(test_instance.printable_target_name).to eq('test_printable_name')
        end
      end
    end

    describe "#unopened_notification_count" do
      it "returns count of unopened notification index" do
        create(:notification, target: test_instance)
        create(:notification, target: test_instance)
        expect(test_instance.unopened_notification_count).to eq(2)
      end

      it "returns count of unopened notification index (owner only)" do
        group_owner  = create(:notification, target: test_instance, group_owner: nil)
                       create(:notification, target: test_instance, group_owner: nil)
        group_member = create(:notification, target: test_instance, group_owner: group_owner)
        expect(test_instance.unopened_notification_count).to eq(2)
      end
    end

    describe "#has_unopened_notifications?" do
      context "when the target has no unopened notifications" do
        it "returns false" do
          expect(test_instance.has_unopened_notifications?).to be_falsey
        end
      end

      context "when the target has unopened notifications" do
        it "returns true" do
          create(:notification, target: test_instance)
          expect(test_instance.has_unopened_notifications?).to be_truthy
        end
      end
    end

    describe "#notification_index" do
      context "when the target has no notifications" do
        it "returns empty records" do
          expect(test_instance.notification_index).to be_empty
        end
      end

      context "when the target has unopened notifications" do
        before do
          @notifiable    = create(:article)
          @group         = create(:article)
          @key           = 'test.key.1'
          @notification2 = create(:notification, target: test_instance, notifiable: @notifiable)
          @notification1 = create(:notification, target: test_instance, notifiable: create(:comment), group: @group, created_at: @notification2.created_at + 10.second)
          @member1       = create(:notification, target: test_instance, notifiable: create(:comment), group_owner: @notification1, created_at: @notification2.created_at + 20.second)
          @notification3 = create(:notification, target: test_instance, notifiable: create(:article), key: @key, created_at: @notification2.created_at + 30.second)
          @notification3.open!
        end

        it "calls unopened_notification_index" do
          expect(test_instance).to receive(:unopened_notification_index).at_least(:once)
          test_instance.notification_index
        end

        context "without any options" do
          it "returns the combined array of unopened_notification_index and opened_notification_index" do
            expect(test_instance.notification_index[0]).to eq(@notification1)
            expect(test_instance.notification_index[1]).to eq(@notification2)
            expect(test_instance.notification_index[2]).to eq(@notification3)
            expect(test_instance.notification_index.size).to eq(3)
          end
        end

        context "with limit" do
          it "returns the same as unopened_notification_index with limit" do
            options = { limit: 1 }
            expect(test_instance.notification_index(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end

        context "with reverse" do
          it "returns the earliest order" do
            options = { reverse: true }
            expect(test_instance.notification_index(options)[0]).to eq(@notification2)
            expect(test_instance.notification_index(options)[1]).to eq(@notification1)
            expect(test_instance.notification_index(options)[2]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(3)
          end
        end

        context "with with_group_members" do
          it "returns the index with group members" do
            options = { with_group_members: true }
            expect(test_instance.notification_index(options)[0]).to eq(@member1)
            expect(test_instance.notification_index(options)[1]).to eq(@notification1)
            expect(test_instance.notification_index(options)[2]).to eq(@notification2)
            expect(test_instance.notification_index(options)[3]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(4)
          end
        end

        context "with as_latest_group_member" do
          it "returns the index as latest group member" do
            options = { as_latest_group_member: true }
            expect(test_instance.notification_index(options)[0]).to eq(@member1)
            expect(test_instance.notification_index(options)[1]).to eq(@notification2)
            expect(test_instance.notification_index(options)[2]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(3)
          end
        end

        context 'with filtered_by_type options' do
          it "returns filtered notifications only" do
            options = { filtered_by_type: 'Article' }
            expect(test_instance.notification_index(options)[0]).to eq(@notification2)
            expect(test_instance.notification_index(options)[1]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(2)
            options = { filtered_by_type: 'Comment' }
            expect(test_instance.notification_index(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end

        context 'with filtered_by_group options' do
          it "returns filtered notifications only" do
            options = { filtered_by_group: @group }
            expect(test_instance.notification_index(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end

        context 'with filtered_by_group_type and :filtered_by_group_id options' do
          it "returns filtered notifications only" do
            options = { filtered_by_group_type: 'Article', filtered_by_group_id: @group.id.to_s }
            expect(test_instance.notification_index(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end

        context 'with filtered_by_key options' do
          it "returns filtered notifications only" do
            options = { filtered_by_key: @key }
            expect(test_instance.notification_index(options)[0]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end

        context 'with custom_filter options' do
          it "returns filtered notifications only" do
            options = { custom_filter: { key: @key } }
            expect(test_instance.notification_index(options)[0]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(1)
          end

          it "returns filtered notifications only with filter depending on ORM" do
            options =
              case ActivityNotification.config.orm
              when :active_record then { custom_filter: ["notifications.key = ?", @key] }
              when :mongoid       then { custom_filter: { key: {'$eq': @key} } }
              when :dynamoid      then { custom_filter: {'key.begins_with': @key} }
              end
            expect(test_instance.notification_index(options)[0]).to eq(@notification3)
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end
      end

      context "when the target has no unopened notifications" do
        before do
          notification = create(:notification, target: test_instance, opened_at: Time.current)
          create(:notification, target: test_instance, opened_at: Time.current, created_at: notification.created_at + 10.second)
        end

        it "calls unopened_notification_index" do
          expect(test_instance).to receive(:opened_notification_index).at_least(:once)
          test_instance.notification_index
        end

        context "without limit" do
          it "returns the same as opened_notification_index" do
            expect(test_instance.notification_index).to eq(test_instance.opened_notification_index)
            expect(test_instance.notification_index.size).to eq(2)
          end
        end

        context "with limit" do
          it "returns the same as opened_notification_index with limit" do
            options = { limit: 1 }
            expect(test_instance.notification_index(options)).to eq(test_instance.opened_notification_index(options))
            expect(test_instance.notification_index(options).size).to eq(1)
          end
        end
      end
    end

    describe "#unopened_notification_index" do
      context "when the target has no notifications" do
        it "returns empty records" do
          expect(test_instance.unopened_notification_index).to be_empty
        end
      end

      context "when the target has unopened notifications" do
        before do
          @notification_1 = create(:notification, target: test_instance)
          @notification_2 = create(:notification, target: test_instance, created_at: @notification_1.created_at + 10.second)
        end

        context "without limit" do
          it "returns unopened notification index" do
            expect(test_instance.unopened_notification_index.size).to eq(2)
            expect(test_instance.unopened_notification_index.last).to  eq(@notification_1)
            expect(test_instance.unopened_notification_index.first).to eq(@notification_2)
          end

          it "returns unopened notification index (owner only)" do
            group_member   = create(:notification, target: test_instance, group_owner: @notification_1)
            expect(test_instance.unopened_notification_index.size).to eq(2)
            expect(test_instance.unopened_notification_index.last).to  eq(@notification_1)
            expect(test_instance.unopened_notification_index.first).to eq(@notification_2)
          end

          it "returns unopened notification index (unopened only)" do
            notification_3 = create(:notification, target: test_instance, opened_at: Time.current)
            expect(test_instance.unopened_notification_index.size).to eq(2)
            expect(test_instance.unopened_notification_index.last).to  eq(@notification_1)
            expect(test_instance.unopened_notification_index.first).to eq(@notification_2)
          end
        end

        context "with limit" do
          it "returns unopened notification index with limit" do
            options = { limit: 1 }
            expect(test_instance.unopened_notification_index(options).size).to eq(1)
            expect(test_instance.unopened_notification_index(options).first).to eq(@notification_2)
          end
        end
      end

      context "when the target has no unopened notifications" do
        before do
          create(:notification, target: test_instance, group_owner: nil, opened_at: Time.current)
          create(:notification, target: test_instance, group_owner: nil, opened_at: Time.current)
        end

        it "returns empty records" do
          expect(test_instance.unopened_notification_index).to be_empty
        end
      end
    end

    describe "#opened_notification_index" do
      context "when the target has no notifications" do
        it "returns empty records" do
          expect(test_instance.opened_notification_index).to be_empty
        end
      end

      context "when the target has opened notifications" do
        before do
          @notification_1 = create(:notification, target: test_instance, opened_at: Time.current)
          @notification_2 = create(:notification, target: test_instance, opened_at: Time.current, created_at: @notification_1.created_at + 10.second)
        end

        context "without limit" do
          it "uses ActivityNotification.config.opened_index_limit as limit" do
            configured_opened_index_limit = ActivityNotification.config.opened_index_limit
            ActivityNotification.config.opened_index_limit = 1
            expect(test_instance.opened_notification_index.size).to eq(1)
            expect(test_instance.opened_notification_index.first).to eq(@notification_2)
            ActivityNotification.config.opened_index_limit = configured_opened_index_limit
          end

          it "returns opened notification index" do
            expect(test_instance.opened_notification_index.size).to eq(2)
            expect(test_instance.opened_notification_index.last).to  eq(@notification_1)
            expect(test_instance.opened_notification_index.first).to eq(@notification_2)
          end

          it "returns opened notification index (owner only)" do
            group_member   = create(:notification, target: test_instance, group_owner: @notification_1, opened_at: Time.current)
            expect(test_instance.opened_notification_index.size).to eq(2)
            expect(test_instance.opened_notification_index.last).to  eq(@notification_1)
            expect(test_instance.opened_notification_index.first).to eq(@notification_2)
          end

          it "returns opened notification index (opened only)" do
            notification_3 = create(:notification, target: test_instance)
            expect(test_instance.opened_notification_index.size).to eq(2)
            expect(test_instance.opened_notification_index.last).to  eq(@notification_1)
            expect(test_instance.opened_notification_index.first).to eq(@notification_2)
          end
        end

        context "with limit" do
          it "returns opened notification index with limit" do
            options = { limit: 1 }
            expect(test_instance.opened_notification_index(options).size).to eq(1)
            expect(test_instance.opened_notification_index(options).first).to eq(@notification_2)
          end
        end
      end

      context "when the target has no opened notifications" do
        before do
          create(:notification, target: test_instance, group_owner: nil)
          create(:notification, target: test_instance, group_owner: nil)
        end

        it "returns empty records" do
          expect(test_instance.opened_notification_index).to be_empty
        end
      end
    end


    # Wrapper methods of Notification class methods

    describe "#receive_notification_of" do
      it "is an alias of ActivityNotification::Notification.notify_to" do
        expect(ActivityNotification::Notification).to receive(:notify_to)
        test_instance.receive_notification_of create(:user)
      end
    end

    describe "#receive_notification_later_of" do
      it "is an alias of ActivityNotification::Notification.notify_later_to" do
        expect(ActivityNotification::Notification).to receive(:notify_later_to)
        test_instance.receive_notification_later_of create(:user)
      end
    end

    describe "#open_all_notifications" do
      it "is an alias of ActivityNotification::Notification.open_all_of" do
        expect(ActivityNotification::Notification).to receive(:open_all_of)
        test_instance.open_all_notifications
      end
    end


    # Methods to be overridden

    describe "#notification_index_with_attributes" do
      context "when the target has no notifications" do
        it "returns empty records" do
          expect(test_instance.notification_index_with_attributes).to be_empty
        end
      end

      context "when the target has unopened notifications" do
        before do
          @notifiable    = create(:article)
          @group         = create(:article)
          @key           = 'test.key.1'
          @notification2 = create(:notification, target: test_instance, notifiable: @notifiable)
          @notification1 = create(:notification, target: test_instance, notifiable: create(:comment), group: @group, created_at: @notification2.created_at + 10.second)
          @notification3 = create(:notification, target: test_instance, notifiable: create(:article), key: @key, created_at: @notification2.created_at + 20.second)
          @notification3.open!
        end

        it "calls unopened_notification_index_with_attributes" do
          expect(test_instance).to receive(:unopened_notification_index_with_attributes).at_least(:once)
          test_instance.notification_index_with_attributes
        end

        context "without any options" do
          it "returns the combined array of unopened_notification_index_with_attributes and opened_notification_index_with_attributes" do
            expect(test_instance.notification_index_with_attributes[0]).to eq(@notification1)
            expect(test_instance.notification_index_with_attributes[1]).to eq(@notification2)
            expect(test_instance.notification_index_with_attributes[2]).to eq(@notification3)
            expect(test_instance.notification_index_with_attributes.size).to eq(3)
          end
        end

        context "with limit" do
          it "returns the same as unopened_notification_index_with_attributes with limit" do
            options = { limit: 1 }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(1)
          end
        end

        context "with reverse" do
          it "returns the earliest order" do
            options = { reverse: true }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification2)
            expect(test_instance.notification_index_with_attributes(options)[1]).to eq(@notification1)
            expect(test_instance.notification_index_with_attributes(options)[2]).to eq(@notification3)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(3)
          end
        end

        context 'with filtered_by_type options' do
          it "returns filtered notifications only" do
            options = { filtered_by_type: 'Article' }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification2)
            expect(test_instance.notification_index_with_attributes(options)[1]).to eq(@notification3)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(2)
            options = { filtered_by_type: 'Comment' }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(1)
          end
        end

        context 'with filtered_by_group options' do
          it "returns filtered notifications only" do
            options = { filtered_by_group: @group }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(1)
          end
        end

        context 'with filtered_by_group_type and :filtered_by_group_id options' do
          it "returns filtered notifications only" do
            options = { filtered_by_group_type: 'Article', filtered_by_group_id: @group.id.to_s }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification1)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(1)
          end
        end

        context 'with filtered_by_key options' do
          it "returns filtered notifications only" do
            options = { filtered_by_key: @key }
            expect(test_instance.notification_index_with_attributes(options)[0]).to eq(@notification3)
            expect(test_instance.notification_index_with_attributes(options).size).to eq(1)
          end
        end
      end

      context "when the target has no unopened notifications" do
        before do
          notification = create(:notification, target: test_instance, opened_at: Time.current)
          create(:notification, target: test_instance, opened_at: Time.current, created_at: notification.created_at + 10.second)
        end

        it "calls unopened_notification_index_with_attributes" do
          expect(test_instance).to receive(:opened_notification_index_with_attributes)
          test_instance.notification_index_with_attributes
        end

        context "without limit" do
          it "returns the same as opened_notification_index_with_attributes" do
            expect(test_instance.notification_index_with_attributes).to eq(test_instance.opened_notification_index_with_attributes)
            expect(test_instance.notification_index_with_attributes.size).to eq(2)
          end
        end

        context "with limit" do
          it "returns the same as opened_notification_index_with_attributes with limit" do
            options = { limit: 1 }
            expect(test_instance.notification_index_with_attributes(options)).to eq(test_instance.opened_notification_index_with_attributes(options))
            expect(test_instance.notification_index_with_attributes(options).size).to eq(1)
          end
        end
      end
    end

    describe "#unopened_notification_index_with_attributes" do
      it "calls _unopened_notification_index" do
        expect(test_instance).to receive(:_unopened_notification_index)
        test_instance.unopened_notification_index_with_attributes
      end

      context "when the target has unopened notifications with no group members" do
        context "with no group members" do
          before do
            create(:notification, target: test_instance)
            create(:notification, target: test_instance)
          end

          if ActivityNotification.config.orm == :active_record
            it "calls with_target, with_notifiable, with_notifier and does not call with_group" do
              expect(ActivityNotification::Notification).to receive_message_chain(:with_target, :with_notifiable, :with_notifier)
              test_instance.unopened_notification_index_with_attributes
            end
          end
        end

        context "with group members" do
          before do
            group_owner  = create(:notification, target: test_instance, group_owner: nil)
                           create(:notification, target: test_instance, group_owner: nil)
            group_member = create(:notification, target: test_instance, group_owner: group_owner)
          end

          if ActivityNotification.config.orm == :active_record
            it "calls with_group" do
              expect(ActivityNotification::Notification).to receive_message_chain(:with_target, :with_notifiable, :with_group, :with_notifier)
              test_instance.unopened_notification_index_with_attributes
            end
          end
        end
      end

      context "when the target has no unopened notifications" do
        before do
          create(:notification, target: test_instance, opened_at: Time.current)
          create(:notification, target: test_instance, opened_at: Time.current)
        end

        it "returns empty records" do
          expect(test_instance.unopened_notification_index_with_attributes).to be_empty
        end
      end
    end

    describe "#opened_notification_index_with_attributes" do
      it "calls _opened_notification_index" do
        expect(test_instance).to receive(:_opened_notification_index)
        test_instance.opened_notification_index_with_attributes
      end

      context "when the target has opened notifications with no group members" do
        context "with no group members" do
          before do
            create(:notification, target: test_instance, opened_at: Time.current)
            create(:notification, target: test_instance, opened_at: Time.current)
          end

          if ActivityNotification.config.orm == :active_record
            it "calls with_target, with_notifiable, with_notifier and does not call with_group" do
              expect(ActivityNotification::Notification).to receive_message_chain(:with_target, :with_notifiable, :with_notifier)
              test_instance.opened_notification_index_with_attributes
            end
          end
        end

        context "with group members" do
          before do
            group_owner  = create(:notification, target: test_instance, group_owner: nil, opened_at: Time.current)
                           create(:notification, target: test_instance, group_owner: nil, opened_at: Time.current)
            group_member = create(:notification, target: test_instance, group_owner: group_owner, opened_at: Time.current)
          end

          if ActivityNotification.config.orm == :active_record
            it "calls with_group" do
              expect(ActivityNotification::Notification).to receive_message_chain(:with_target, :with_notifiable, :with_group, :with_notifier)
              test_instance.opened_notification_index_with_attributes
            end
          end
        end
      end

      context "when the target has no opened notifications" do
        before do
          create(:notification, target: test_instance)
          create(:notification, target: test_instance)
        end

        it "returns empty records" do
          expect(test_instance.opened_notification_index_with_attributes).to be_empty
        end
      end
    end

    describe "#send_notification_email" do
      context "with right target of notification" do
        before do
          @notification = create(:notification, target: test_instance)
        end

        it "calls notification.send_notification_email" do
          expect(@notification).to receive(:send_notification_email).at_least(:once)
          test_instance.send_notification_email(@notification)
        end
      end

      context "with wrong target of notification" do
        before do
          @notification = create(:notification, target: create(:user))
        end

        it "does not call notification.send_notification_email" do
          expect(@notification).not_to receive(:send_notification_email)
          test_instance.send_notification_email(@notification)
        end

        it "returns nil" do
          expect(test_instance.send_notification_email(@notification)).to be_nil
        end
      end
    end

    describe "#send_batch_notification_email" do
      context "with right target of notification" do
        before do
          @notifications = [create(:notification, target: test_instance), create(:notification, target: test_instance)]
        end

        it "calls ActivityNotification::Notification.send_batch_notification_email" do
          expect(ActivityNotification::Notification).to receive(:send_batch_notification_email).at_least(:once)
          test_instance.send_batch_notification_email(@notifications)
        end
      end

      context "with wrong target of notification" do
        before do
          notifications = [create(:notification, target: test_instance), create(:notification, target: create(:user))]
        end

        it "does not call ActivityNotification::Notification.send_batch_notification_email" do
          expect(ActivityNotification::Notification).not_to receive(:send_batch_notification_email)
          test_instance.send_batch_notification_email(@notifications)
        end

        it "returns nil" do
          expect(test_instance.send_batch_notification_email(@notifications)).to be_nil
        end
      end
    end

    describe "#subscribes_to_notification?" do
      context "when the subscription is not enabled for the target" do
        it "returns true" do
          described_class._notification_subscription_allowed = false
          expect(test_instance.subscribes_to_notification?('test_key')).to be_truthy
        end
      end

      context "when the subscription is enabled for the target" do
        it "calls Subscriber#_subscribes_to_notification?" do
          described_class._notification_subscription_allowed = true
          expect(test_instance).to receive(:_subscribes_to_notification?)
          test_instance.subscribes_to_notification?('test_key')
        end
      end
    end

    describe "#subscribes_to_notification_email?" do
      context "when the subscription is not enabled for the target" do
        it "returns true" do
          described_class._notification_subscription_allowed = false
          expect(test_instance.subscribes_to_notification_email?('test_key')).to be_truthy
        end
      end

      context "when the subscription is enabled for the target" do
        it "calls Subscriber#_subscribes_to_notification_email?" do
          described_class._notification_subscription_allowed = true
          expect(test_instance).to receive(:_subscribes_to_notification_email?)
          test_instance.subscribes_to_notification_email?('test_key')
        end
      end
    end

    describe "#subscribes_to_optional_target?" do
      context "when the subscription is not enabled for the target" do
        it "returns true" do
          described_class._notification_subscription_allowed = false
          expect(test_instance.subscribes_to_optional_target?('test_key', :slack)).to be_truthy
        end
      end

      context "when the subscription is enabled for the target" do
        it "calls Subscriber#_subscribes_to_optional_target?" do
          described_class._notification_subscription_allowed = true
          expect(test_instance).to receive(:_subscribes_to_optional_target?)
          test_instance.subscribes_to_optional_target?('test_key', :slack)
        end
      end
    end
  end

end