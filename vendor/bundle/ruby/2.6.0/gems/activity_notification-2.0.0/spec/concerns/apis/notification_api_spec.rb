shared_examples_for :notification_api do
  include ActiveJob::TestHelper
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }
  let(:notifiable_class) { test_instance.notifiable.class }
  before do
    ActiveJob::Base.queue_adapter = :test
    ActivityNotification::Mailer.deliveries.clear
    expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
  end

  describe "as public class methods" do
    before do
      @author_user = create(:confirmed_user)
      @user_1      = create(:confirmed_user)
      @user_2      = create(:confirmed_user)
      @article     = create(:article, user: @author_user)
      @comment_1   = create(:comment, article: @article, user: @user_1)
      @comment_2   = create(:comment, article: @article, user: @user_2)
      expect(@author_user.notifications.count).to eq(0)
      expect(@user_1.notifications.count).to eq(0)
      expect(@user_2.notifications.count).to eq(0)
    end

    describe ".notify" do
      it "returns array of created notifications" do
        notifications = described_class.notify(:users, @comment_2)
        expect(notifications).to be_a Array
        expect(notifications.size).to eq(2)
        if notifications[0].target == @author_user
          validate_expected_notification(notifications[0], @author_user, @comment_2)
          validate_expected_notification(notifications[1], @user_1, @comment_2)
        else
          validate_expected_notification(notifications[0], @user_1, @comment_2)
          validate_expected_notification(notifications[1], @author_user, @comment_2)
        end
      end

      it "creates notification records" do
        described_class.notify(:users, @comment_2)
        expect(@author_user.notifications.unopened_only.count).to eq(1)
        expect(@user_1.notifications.unopened_only.count).to eq(1)
        expect(@user_2.notifications.unopened_only.count).to eq(0)
      end

      context "as default" do
        it "sends notification email later" do
          expect {
            perform_enqueued_jobs do
              described_class.notify(:users, @comment_2)
            end
          }.to change { ActivityNotification::Mailer.deliveries.size }.by(2)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(2)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@author_user.email)
          expect(ActivityNotification::Mailer.deliveries.last.to[0]).to eq(@user_1.email)
        end
  
        it "sends notification email with active job queue" do
          expect {
            described_class.notify(:users, @comment_2)
          }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
        end
      end

      context "with notify_later true" do
        it "generates notifications later" do
          expect {
            described_class.notify(:users, @comment_2, notify_later: true)
          }.to have_enqueued_job(ActivityNotification::NotifyJob)
        end

        it "creates notification records later" do
          perform_enqueued_jobs do
            described_class.notify(:users, @comment_2, notify_later: true)
          end
          expect(@author_user.notifications.unopened_only.count).to eq(1)
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_2.notifications.unopened_only.count).to eq(0)
        end
      end

      context "with send_later false" do
        it "sends notification email now" do
          described_class.notify(:users, @comment_2, send_later: false)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(2)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@author_user.email)
          expect(ActivityNotification::Mailer.deliveries.last.to[0]).to eq(@user_1.email)
        end
      end

      context "with pass_full_options" do
        before do
          @original_targets = Comment._notification_targets[:users]
        end

        after do
          Comment._notification_targets[:users] = @original_targets
        end

        context "as false (as default)" do
          it "accepts specified lambda with notifiable and key arguments" do
            Comment._notification_targets[:users] = ->(notifiable, key){ User.all if key == 'dummy_key' }
            described_class.notify(:users, @comment_2, key: 'dummy_key')
            expect(@author_user.notifications.unopened_only.count).to eq(1)
          end

          it "cannot accept specified lambda with notifiable and options arguments" do
            Comment._notification_targets[:users] = ->(notifiable, options){ User.all if options[:key] == 'dummy_key' }
            expect { described_class.notify(:users, @comment_2, key: 'dummy_key') }.to raise_error(TypeError)
          end
        end

        context "as true" do
          it "cannot accept specified lambda with notifiable and key arguments" do
            Comment._notification_targets[:users] = ->(notifiable, key){ User.all if key == 'dummy_key' }
            expect { described_class.notify(:users, @comment_2, key: 'dummy_key', pass_full_options: true) }.to raise_error(NotImplementedError)
          end

          it "accepts specified lambda with notifiable and options arguments" do
            Comment._notification_targets[:users] = ->(notifiable, options){ User.all if options[:key] == 'dummy_key' }
            described_class.notify(:users, @comment_2, key: 'dummy_key', pass_full_options: true)
            expect(@author_user.notifications.unopened_only.count).to eq(1)
          end
        end
      end
    end

    describe ".notify_later" do
      it "generates notifications later" do
        expect {
          described_class.notify_later(:users, @comment_2)
        }.to have_enqueued_job(ActivityNotification::NotifyJob)
      end

      it "creates notification records later" do
        perform_enqueued_jobs do
          described_class.notify_later(:users, @comment_2)
        end
        expect(@author_user.notifications.unopened_only.count).to eq(1)
        expect(@user_1.notifications.unopened_only.count).to eq(1)
        expect(@user_2.notifications.unopened_only.count).to eq(0)
      end
    end

    describe ".notify_all" do
      it "returns array of created notifications" do
        notifications = described_class.notify_all([@author_user, @user_1], @comment_2)
        expect(notifications).to be_a Array
        expect(notifications.size).to eq(2)
        validate_expected_notification(notifications[0], @author_user, @comment_2)
        validate_expected_notification(notifications[1], @user_1, @comment_2)
      end

      it "creates notification records" do
        described_class.notify_all([@author_user, @user_1], @comment_2)
        expect(@author_user.notifications.unopened_only.count).to eq(1)
        expect(@user_1.notifications.unopened_only.count).to eq(1)
        expect(@user_2.notifications.unopened_only.count).to eq(0)
      end

      context "as default" do
        it "sends notification email later" do
          expect {
            perform_enqueued_jobs do
              described_class.notify_all([@author_user, @user_1], @comment_2)
            end
          }.to change { ActivityNotification::Mailer.deliveries.size }.by(2)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(2)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@author_user.email)
          expect(ActivityNotification::Mailer.deliveries.last.to[0]).to eq(@user_1.email)
        end

        it "sends notification email with active job queue" do
          expect {
            described_class.notify_all([@author_user, @user_1], @comment_2)
          }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
        end
      end

      context "with notify_later true" do
        it "generates notifications later" do
          expect {
            described_class.notify_all([@author_user, @user_1], @comment_2, notify_later: true)
          }.to have_enqueued_job(ActivityNotification::NotifyAllJob)
        end

        it "creates notification records later" do
          perform_enqueued_jobs do
            described_class.notify_all([@author_user, @user_1], @comment_2, notify_later: true)
          end
          expect(@author_user.notifications.unopened_only.count).to eq(1)
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_2.notifications.unopened_only.count).to eq(0)
        end
      end

      context "with send_later false" do
        it "sends notification email now" do
          described_class.notify_all([@author_user, @user_1], @comment_2, send_later: false)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(2)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@author_user.email)
          expect(ActivityNotification::Mailer.deliveries.last.to[0]).to eq(@user_1.email)
        end
      end
    end

    describe ".notify_all_later" do
      it "generates notifications later" do
        expect {
          described_class.notify_all_later([@author_user, @user_1], @comment_2)
        }.to have_enqueued_job(ActivityNotification::NotifyAllJob)
      end

      it "creates notification records later" do
        perform_enqueued_jobs do
          described_class.notify_all_later([@author_user, @user_1], @comment_2)
        end
        expect(@author_user.notifications.unopened_only.count).to eq(1)
        expect(@user_1.notifications.unopened_only.count).to eq(1)
        expect(@user_2.notifications.unopened_only.count).to eq(0)
      end
    end

    describe ".notify_to" do
      it "returns created notification" do
        notification = described_class.notify_to(@user_1, @comment_2)
        validate_expected_notification(notification, @user_1, @comment_2)
      end

      it "creates notification records" do
        described_class.notify_to(@user_1, @comment_2)
        expect(@user_1.notifications.unopened_only.count).to eq(1)
        expect(@user_2.notifications.unopened_only.count).to eq(0)
      end

      context "as default" do
        it "sends notification email later" do
          expect {
            perform_enqueued_jobs do
              described_class.notify_to(@user_1, @comment_2)
            end
          }.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@user_1.email)
        end

        it "sends notification email with active job queue" do
          expect {
            described_class.notify_to(@user_1, @comment_2)
          }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
        end
      end

      context "with notify_later true" do
        it "generates notifications later" do
          expect {
            described_class.notify_to(@user_1, @comment_2, notify_later: true)
          }.to have_enqueued_job(ActivityNotification::NotifyToJob)
        end

        it "creates notification records later" do
          perform_enqueued_jobs do
            described_class.notify_to(@user_1, @comment_2, notify_later: true)
          end
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_2.notifications.unopened_only.count).to eq(0)
        end
      end

      context "with send_later false" do
        it "sends notification email now" do
          described_class.notify_to(@user_1, @comment_2, send_later: false)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(@user_1.email)
        end
      end

      context "with options" do
        context "as default" do
          let(:created_notification) { 
            described_class.notify_to(@user_1, @comment_2)
            @user_1.notifications.latest
          }

          it "has key of notifiable.default_notification_key" do
            expect(created_notification.key)
              .to eq(created_notification.notifiable.default_notification_key)
          end

          it "has group of notifiable.notification_group" do
            expect(created_notification.group)
              .to eq(
                created_notification.notifiable.notification_group(
                  @user_1.class,
                  created_notification.key
                )
              )
          end

          it "has notifier of notifiable.notifier" do
            expect(created_notification.notifier)
              .to eq(
                created_notification.notifiable.notifier(
                  @user_1.class,
                  created_notification.key
                )
              )
          end

          it "has parameters of notifiable.notification_parameters" do
            expect(created_notification.parameters.stringify_keys)
              .to eq(
                created_notification.notifiable.notification_parameters(
                  @user_1.class,
                  created_notification.key
                )
              )
          end
        end

        context "as specified default value" do
          let(:created_notification) { 
            described_class.notify_to(@user_1, @comment_2)
          }

          it "has key of [notifiable_class_name].default" do
            expect(created_notification.key).to eq('comment.default')
          end

          it "has group of group in acts_as_notifiable" do
            expect(created_notification.group).to eq(@article)
          end

          it "has notifier of notifier in acts_as_notifiable" do
            expect(created_notification.notifier).to eq(@user_2)
          end

          it "has parameters of parameters in acts_as_notifiable" do
            expect(created_notification.parameters).to eq({'test_default_param' => '1'})
          end
        end

        context "as api options" do
          let(:created_notification) { 
            described_class.notify_to(
              @user_1, @comment_2,
              key: 'custom_test_key',
              group: @comment_2,
              notifier: @author_user,
              parameters: {custom_param_1: '1'},
              custom_param_2: '2'
            )
          }

          it "has key of key option" do
            expect(created_notification.key).to eq('custom_test_key')
          end

          it "has group of group option" do
            expect(created_notification.group).to eq(@comment_2)
          end

          it "has notifier of notifier option" do
            expect(created_notification.notifier).to eq(@author_user)
          end

          it "has parameters of parameters option" do
            expect(created_notification.parameters[:custom_param_1]).to eq('1')
          end

          it "has parameters from custom options" do
            expect(created_notification.parameters[:custom_param_2]).to eq('2')
          end
        end
      end

      context "with grouping" do
        it "creates group by specified group and the target" do
          owner_notification  = described_class.notify_to(@user_1, @comment_1, group: @article)
          member_notification = described_class.notify_to(@user_1, @comment_2, group: @article)
          expect(member_notification.group_owner).to eq(owner_notification)
        end

        it "belongs to single group" do
          owner_notification    = described_class.notify_to(@user_1, @comment_1, group: @article)
          member_notification_1 = described_class.notify_to(@user_1, @comment_2, group: @article)
          member_notification_2 = described_class.notify_to(@user_1, @comment_2, group: @article)
          expect(member_notification_1.group_owner).to eq(owner_notification)
          expect(member_notification_2.group_owner).to eq(owner_notification)
        end

        it "does not create group with opened notifications" do
          owner_notification  = described_class.notify_to(@user_1, @comment_1, group: @article)
          owner_notification.open!
          member_notification = described_class.notify_to(@user_1, @comment_2, group: @article)
          expect(member_notification.group_owner).to eq(nil)
        end

        it "does not create group with different target" do
          owner_notification  = described_class.notify_to(@user_1, @comment_1, group: @article)
          member_notification = described_class.notify_to(@user_2, @comment_2, group: @article)
          expect(member_notification.group_owner).to eq(nil)
        end

        it "does not create group with different group" do
          owner_notification  = described_class.notify_to(@user_1, @comment_1, group: @article)
          member_notification = described_class.notify_to(@user_1, @comment_2, group: @comment_2)
          expect(member_notification.group_owner).to eq(nil)
        end

        it "does not create group with different notifiable type" do
          owner_notification  = described_class.notify_to(@user_1, @comment_1, group: @article)
          member_notification = described_class.notify_to(@user_1, @article,   group: @article)
          expect(member_notification.group_owner).to eq(nil)
        end

        it "does not create group with different key" do
          owner_notification  = described_class.notify_to(@user_1, @comment_1, key: 'key1', group: @article)
          member_notification = described_class.notify_to(@user_1, @comment_2, key: 'key2', group: @article)
          expect(member_notification.group_owner).to eq(nil)
        end

        context "with group_expiry_delay option" do
          context "within the group expiry period" do
            it "belongs to single group" do
              owner_notification    = described_class.notify_to(@user_1, @comment_1, group: @article, group_expiry_delay: 1.day)
              member_notification_1 = described_class.notify_to(@user_1, @comment_2, group: @article, group_expiry_delay: 1.day)
              member_notification_2 = described_class.notify_to(@user_1, @comment_2, group: @article, group_expiry_delay: 1.day)
              expect(member_notification_1.group_owner).to eq(owner_notification)
              expect(member_notification_2.group_owner).to eq(owner_notification)
            end
          end

          context "out of the group expiry period" do
            it "does not belong to single group" do
              Timecop.travel(90.seconds.ago)
              owner_notification    = described_class.notify_to(@user_1, @comment_1, group: @article, group_expiry_delay: 1.minute)
              member_notification_1 = described_class.notify_to(@user_1, @comment_2, group: @article, group_expiry_delay: 1.minute)
              Timecop.return
              member_notification_2 = described_class.notify_to(@user_1, @comment_2, group: @article, group_expiry_delay: 1.minute)
              expect(member_notification_1.group_owner).to eq(owner_notification)
              expect(member_notification_2.group_owner).to be_nil
            end
          end
        end
      end
    end

    describe ".notify_later_to" do
      it "generates notifications later" do
        expect {
          described_class.notify_later_to(@user_1, @comment_2)
        }.to have_enqueued_job(ActivityNotification::NotifyToJob)
      end

      it "creates notification records later" do
        perform_enqueued_jobs do
          described_class.notify_later_to(@user_1, @comment_2)
        end
        expect(@user_1.notifications.unopened_only.count).to eq(1)
        expect(@user_2.notifications.unopened_only.count).to eq(0)
      end
    end

    describe ".open_all_of" do
      before do
        described_class.notify_to(@user_1, @article, group: @article, key: 'key.1')
        described_class.notify_to(@user_1, @comment_2, group: @comment_2, key: 'key.2')
        expect(@user_1.notifications.unopened_only.count).to eq(2)
        expect(@user_1.notifications.opened_only!.count).to eq(0)
      end

      it "returns the number of opened notification records" do
        expect(described_class.open_all_of(@user_1)).to eq(2)
      end

      it "opens all notifications of the target" do
        described_class.open_all_of(@user_1)
        expect(@user_1.notifications.unopened_only.count).to eq(0)
        expect(@user_1.notifications.opened_only!.count).to eq(2)
      end

      it "does not open any notifications of the other targets" do
        described_class.open_all_of(@user_2)
        expect(@user_1.notifications.unopened_only.count).to eq(2)
        expect(@user_1.notifications.opened_only!.count).to eq(0)
      end

      it "opens all notification with current time" do
        expect(@user_1.notifications.first.opened_at).to be_nil
        Timecop.freeze(Time.current)
        described_class.open_all_of(@user_1)
        expect(@user_1.notifications.first.opened_at.to_i).to eq(Time.current.to_i)
        Timecop.return
      end

      context "with opened_at option" do
        it "opens all notification with specified time" do
          expect(@user_1.notifications.first.opened_at).to be_nil
          opened_at = Time.current - 1.months
          described_class.open_all_of(@user_1, opened_at: opened_at)
          expect(@user_1.notifications.first.opened_at.to_i).to eq(opened_at.to_i)
        end
      end

      context 'with filtered_by_type options' do
        it "opens filtered notifications only" do
          described_class.open_all_of(@user_1, { filtered_by_type: @comment_2.to_class_name })
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_1.notifications.opened_only!.count).to eq(1)
        end
      end

      context 'with filtered_by_group options' do
        it "opens filtered notifications only" do
          described_class.open_all_of(@user_1, { filtered_by_group: @comment_2 })
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_1.notifications.opened_only!.count).to eq(1)
        end
      end

      context 'with filtered_by_group_type and :filtered_by_group_id options' do
        it "opens filtered notifications only" do
          described_class.open_all_of(@user_1, { filtered_by_group_type: 'Comment', filtered_by_group_id: @comment_2.id.to_s })
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_1.notifications.opened_only!.count).to eq(1)
        end
      end

      context 'with filtered_by_key options' do
        it "opens filtered notifications only" do
          described_class.open_all_of(@user_1, { filtered_by_key: 'key.2' })
          expect(@user_1.notifications.unopened_only.count).to eq(1)
          expect(@user_1.notifications.opened_only!.count).to eq(1)
        end
      end
    end

    describe ".group_member_exists?" do
      context "when specified notifications have any group members" do
        let(:owner_notifications) do
          target       = create(:confirmed_user)
          group_owner  = create(:notification, target: target, group_owner: nil)
                         create(:notification, target: target, group_owner: nil)
          group_member = create(:notification, target: target, group_owner: group_owner)
          target.notifications.group_owners_only
        end

        it "returns true for DB query" do
          expect(described_class.group_member_exists?(owner_notifications))
            .to be_truthy
        end

        it "returns true for Array" do
          expect(described_class.group_member_exists?(owner_notifications.to_a))
            .to be_truthy
        end
      end

      context "when specified notifications have no group members" do
        let(:owner_notifications) do
          target       = create(:confirmed_user)
          group_owner  = create(:notification, target: target, group_owner: nil)
                         create(:notification, target: target, group_owner: nil)
          target.notifications.group_owners_only
        end

        it "returns false" do
          expect(described_class.group_member_exists?(owner_notifications))
            .to be_falsey
        end
      end
    end

    describe ".send_batch_notification_email" do
      context "as default" do
        it "sends batch notification email later" do
          expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
          expect {
            perform_enqueued_jobs do
              described_class.send_batch_notification_email(test_instance.target, [test_instance])
            end
          }.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(test_instance.target.email)
        end

        it "sends batch notification email with active job queue" do
          expect {
            described_class.send_batch_notification_email(test_instance.target, [test_instance])
          }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
        end
      end

      context "with send_later false" do
        it "sends notification email now" do
          expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
          described_class.send_batch_notification_email(test_instance.target, [test_instance], send_later: false)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(test_instance.target.email)
        end
      end
    end

    describe ".available_options" do
      it "returns list of available options in notify api" do
        expect(described_class.available_options)
          .to eq([:key, :group, :group_expiry_delay, :notifier, :parameters, :send_email, :send_later])
      end
    end
  end

  describe "as private class methods" do
    describe ".store_notification" do
      it "is defined as private method" do
        expect(described_class.respond_to?(:store_notification)).to       be_falsey
        expect(described_class.respond_to?(:store_notification, true)).to be_truthy
      end
    end
  end

  describe "as public instance methods" do
    describe "#send_notification_email" do
      context "as default" do
        it "sends notification email later" do
          expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
          expect {
            perform_enqueued_jobs do
              test_instance.send_notification_email
            end
          }.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(test_instance.target.email)
        end

        it "sends notification email with active job queue" do
          expect {
            test_instance.send_notification_email
          }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
        end
      end

      context "with send_later false" do
        it "sends notification email now" do
          expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
          test_instance.send_notification_email send_later: false
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
          expect(ActivityNotification::Mailer.deliveries.first.to[0]).to eq(test_instance.target.email)
        end
      end
    end

    describe "#publish_to_optional_targets" do
      before do
        require 'custom_optional_targets/console_output'
        @optional_target = CustomOptionalTarget::ConsoleOutput.new(console_out: false)
        notifiable_class.acts_as_notifiable test_instance.target.to_resources_name.to_sym, optional_targets: ->{ [@optional_target] }
        expect(test_instance.notifiable.optional_targets(test_instance.target.to_resources_name, test_instance.key)).to eq([@optional_target])
      end

      context "subscribed by target" do
        before do
          test_instance.target.create_subscription(key: test_instance.key, optional_targets: { subscribing_to_console_output: true })
          expect(test_instance.optional_target_subscribed?(:console_output)).to be_truthy
        end

        it "calls OptionalTarget#notify" do
          expect(@optional_target).to receive(:notify)
          test_instance.publish_to_optional_targets
        end

        it "returns truthy result hash" do
          expect(test_instance.publish_to_optional_targets).to eq({ console_output: true })
        end
      end

      context "unsubscribed by target" do
        before do
          test_instance.target.create_subscription(key: test_instance.key, optional_targets: { subscribing_to_console_output: false })
          expect(test_instance.optional_target_subscribed?(:console_output)).to be_falsey
        end

        it "does not call OptionalTarget#notify" do
          expect(@optional_target).not_to receive(:notify)
          test_instance.publish_to_optional_targets
        end

        it "returns truthy result hash" do
          expect(test_instance.publish_to_optional_targets).to eq({ console_output: false })
        end
      end
    end

    describe "#open!" do
      it "returns the number of opened notification records" do
        expect(test_instance.open!).to eq(1)
      end

      it "returns the number of opened notification records including group members" do
        group_member = create(test_class_name, group_owner: test_instance)
        expect(group_member.opened_at.blank?).to be_truthy
        expect(test_instance.open!).to eq(2)
      end

      context "as default" do
        it "open notification with current time" do
          expect(test_instance.opened_at.blank?).to be_truthy
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.open!
          expect(test_instance.opened_at.blank?).to be_falsey
          expect(test_instance.opened_at).to        eq(Time.current)
          Timecop.return
        end

        it "open group member notifications with current time" do
          group_member = create(test_class_name, group_owner: test_instance)
          expect(group_member.opened_at.blank?).to be_truthy
          Timecop.freeze(Time.at(Time.now.to_i))
          test_instance.open!
          group_member = group_member.reload
          expect(group_member.opened_at.blank?).to be_falsey
          expect(group_member.opened_at.to_i).to   eq(Time.current.to_i)
          Timecop.return
        end
      end

      context "with opened_at option" do
        it "open notification with specified time" do
          expect(test_instance.opened_at.blank?).to be_truthy
          opened_at = Time.current - 1.months
          test_instance.open!(opened_at: opened_at)
          expect(test_instance.opened_at.blank?).to be_falsey
          expect(test_instance.opened_at.to_i).to        eq(opened_at.to_i)
        end

        it "open group member notifications with specified time" do
          group_member = create(test_class_name, group_owner: test_instance)
          expect(group_member.opened_at.blank?).to be_truthy
          opened_at = Time.current - 1.months
          test_instance.open!(opened_at: opened_at)
          group_member = group_member.reload
          expect(group_member.opened_at.blank?).to be_falsey
          expect(group_member.opened_at.to_i).to   eq(opened_at.to_i)
        end
      end

      context "with false as with_members" do
        it "does not open group member notifications" do
          group_member = create(test_class_name, group_owner: test_instance)
          expect(group_member.opened_at.blank?).to be_truthy
          opened_at = Time.current - 1.months
          test_instance.open!(with_members: false)
          group_member = group_member.reload
          expect(group_member.opened_at.blank?).to be_truthy
        end

        it "returns the number of opened notification records" do
          create(test_class_name, group_owner: test_instance, opened_at: nil)
          expect(test_instance.open!(with_members: false)).to eq(1)
        end
      end
    end

    describe "#unopened?" do
      context "when opened_at is blank" do
        it "returns true" do
          expect(test_instance.unopened?).to be_truthy
        end
      end

      context "when opened_at is present" do
        it "returns false" do
          test_instance.open!
          expect(test_instance.unopened?).to be_falsey
        end
      end
    end
      
    describe "#opened?" do
      context "when opened_at is blank" do
        it "returns false" do
          expect(test_instance.opened?).to be_falsey
        end
      end

      context "when opened_at is present" do
        it "returns true" do
          test_instance.open!
          expect(test_instance.opened?).to be_truthy
        end
      end
    end

    describe "#group_owner?" do
      context "when the notification is group owner" do
        it "returns true" do
          expect(test_instance.group_owner?).to be_truthy
        end
      end

      context "when the notification belongs to group" do
        it "returns false" do
          group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
          expect(group_member.group_owner?).to be_falsey
        end
      end
    end

    describe "#group_member?" do
      context "when the notification is group owner" do
        it "returns false" do
          expect(test_instance.group_member?).to be_falsey
        end
      end

      context "when the notification belongs to group" do
        it "returns true" do
          group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
          expect(group_member.group_member?).to be_truthy
        end
      end
    end

    describe "#group_member_exists?" do
      context "when the notification is group owner and has no group members" do
        it "returns false" do
          expect(test_instance.group_member_exists?).to be_falsey
        end
      end

      context "when the notification is group owner and has group members" do
        it "returns true" do
          create(test_class_name, target: test_instance.target, group_owner: test_instance)
          expect(test_instance.group_member_exists?).to be_truthy
        end
      end

      context "when the notification belongs to group" do
        it "returns true" do
          group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
          expect(group_member.group_member_exists?).to be_truthy
        end
      end
    end

    # Returns if group member notifier except group owner notifier exists.
    # It always returns false if group owner notifier is blank.
    # It counts only the member notifier of the same type with group owner notifier.
    describe "#group_member_notifier_exists?" do
      context "with notifier" do
        before do
          test_instance.update(notifier: create(:user))
        end

        context "when the notification is group owner and has no group members" do
          it "returns false" do
            expect(test_instance.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification is group owner and has group members with the same notifier with the owner's" do
          it "returns false" do
            create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
            expect(test_instance.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification is group owner and has group members with different notifier from the owner's" do
          it "returns true" do
            create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
            expect(test_instance.group_member_notifier_exists?).to be_truthy
          end
        end

        context "when the notification belongs to group and has group members with the same notifier with the owner's" do
          it "returns false" do
            group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
            expect(group_member.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification belongs to group and has group members with different notifier from the owner's" do
          it "returns true" do
            group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
            expect(group_member.group_member_notifier_exists?).to be_truthy
          end
        end
      end

      context "without notifier" do
        before do
          test_instance.update(notifier: nil)
        end

        context "when the notification is group owner and has no group members" do
          it "returns false" do
            expect(test_instance.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification is group owner and has group members without notifier" do
          it "returns false" do
            create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: nil)
            expect(test_instance.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification is group owner and has group members with notifier" do
          it "returns false" do
            create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
            expect(test_instance.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification belongs to group and has group members without notifier" do
          it "returns false" do
            group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: nil)
            expect(group_member.group_member_notifier_exists?).to be_falsey
          end
        end

        context "when the notification belongs to group and has group members with notifier" do
          it "returns false" do
            group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
            expect(group_member.group_member_notifier_exists?).to be_falsey
          end
        end
      end
    end

    describe "#group_member_count (with #group_notification_count)" do
      context "for unopened notification" do
        context "when the notification is group owner and has no group members" do
          it "returns 0" do
            expect(test_instance.group_member_count).to eq(0)
            expect(test_instance.group_notification_count).to eq(1)
          end
        end

        context "when the notification is group owner and has group members" do
          it "returns member count" do
            create(test_class_name, target: test_instance.target, group_owner: test_instance)
            create(test_class_name, target: test_instance.target, group_owner: test_instance)
            expect(test_instance.group_member_count).to eq(2)
            expect(test_instance.group_notification_count).to eq(3)
          end
        end

        context "when the notification belongs to group" do
          it "returns member count" do
            group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
                           create(test_class_name, target: test_instance.target, group_owner: test_instance)
            expect(group_member.group_member_count).to eq(2)
            expect(group_member.group_notification_count).to eq(3)
          end
        end
      end

      context "for opened notification" do
        context "when the notification is group owner and has no group members" do
          it "returns 0" do
            test_instance.open!
            expect(test_instance.group_member_count).to eq(0)
            expect(test_instance.group_notification_count).to eq(1)
          end
        end

        context "as default" do
          context "when the notification is group owner and has group members" do
            it "returns member count" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance)
              create(test_class_name, target: test_instance.target, group_owner: test_instance)
              test_instance.open!
              expect(test_instance.group_member_count).to eq(2)
              expect(test_instance.group_notification_count).to eq(3)
            end
          end

          context "when the notification belongs to group" do
            it "returns member count" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
                             create(test_class_name, target: test_instance.target, group_owner: test_instance)
              test_instance.open!
              expect(group_member.group_member_count).to eq(2)
              expect(group_member.group_notification_count).to eq(3)
            end
          end
        end

        context "with limit" do
          context "when the notification is group owner and has group members" do
            it "returns member count by limit 0" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance)
              create(test_class_name, target: test_instance.target, group_owner: test_instance)
              test_instance.open!
              expect(test_instance.group_member_count(0)).to eq(0)
              expect(test_instance.group_notification_count(0)).to eq(1)
            end

            it "returns member count by limit 1" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance)
              create(test_class_name, target: test_instance.target, group_owner: test_instance)
              test_instance.open!
              expect(test_instance.group_member_count(1)).to eq(1)
              expect(test_instance.group_notification_count(1)).to eq(2)
            end
          end

          context "when the notification belongs to group" do
            it "returns member count by limit 0" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
                             create(test_class_name, target: test_instance.target, group_owner: test_instance)
              test_instance.open!
              expect(group_member.group_member_count(0)).to eq(0)
              expect(group_member.group_notification_count(0)).to eq(1)
            end

            it "returns member count by limit 1" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance)
                             create(test_class_name, target: test_instance.target, group_owner: test_instance)
              test_instance.open!
              expect(group_member.group_member_count(1)).to eq(1)
              expect(group_member.group_notification_count(1)).to eq(2)
            end
          end
        end
      end
    end

    # Returns count of group member notifiers of the notification not including group owner notifier.
    # It always returns 0 if group owner notifier is blank.
    # It counts only the member notifier of the same type with group owner notifier.
    describe "#group_member_notifier_count (with #group_notifier_count)" do
      context "for unopened notification" do
        context "with notifier" do
          before do
            test_instance.update(notifier: create(:user))
          end

          context "when the notification is group owner and has no group members" do
            it "returns 0" do
              expect(test_instance.group_member_notifier_count).to eq(0)
              expect(test_instance.group_notifier_count).to eq(1)
            end
          end

          context "when the notification is group owner and has group members with the same notifier with the owner's" do
            it "returns 0" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
              expect(test_instance.group_member_notifier_count).to eq(0)
              expect(test_instance.group_notifier_count).to eq(1)
            end
          end

          context "when the notification is group owner and has group members with different notifier from the owner's" do
            it "returns member notifier count" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              expect(test_instance.group_member_notifier_count).to eq(2)
              expect(test_instance.group_notifier_count).to eq(3)
            end

            it "returns member notifier count with selecting distinct notifier" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: group_member.notifier)
              expect(test_instance.group_member_notifier_count).to eq(1)
              expect(test_instance.group_notifier_count).to eq(2)
            end
          end

          context "when the notification belongs to group and has group members with the same notifier with the owner's" do
            it "returns 0" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
              expect(group_member.group_member_notifier_count).to eq(0)
              expect(group_member.group_notifier_count).to eq(1)
            end
          end

          context "when the notification belongs to group and has group members with different notifier from the owner's" do
            it "returns member notifier count" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              expect(group_member.group_member_notifier_count).to eq(2)
              expect(group_member.group_notifier_count).to eq(3)
            end

            it "returns member notifier count with selecting distinct notifier" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: group_member.notifier)
              expect(group_member.group_member_notifier_count).to eq(1)
              expect(group_member.group_notifier_count).to eq(2)
            end
          end
        end

        context "without notifier" do
          before do
            test_instance.update(notifier: nil)
          end

          context "when the notification is group owner and has no group members" do
            it "returns 0" do
              expect(test_instance.group_member_notifier_count).to eq(0)
              expect(test_instance.group_notifier_count).to eq(0)
            end
          end

          context "when the notification is group owner and has group members with the same notifier with the owner's" do
            it "returns 0" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
              expect(test_instance.group_member_notifier_count).to eq(0)
              expect(test_instance.group_notifier_count).to eq(0)
            end
          end

          context "when the notification is group owner and has group members with different notifier from the owner's" do
            it "returns 0" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              expect(test_instance.group_member_notifier_count).to eq(0)
              expect(test_instance.group_notifier_count).to eq(0)
            end
          end

          context "when the notification belongs to group and has group members with the same notifier with the owner's" do
            it "returns 0" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
              expect(group_member.group_member_notifier_count).to eq(0)
              expect(group_member.group_notifier_count).to eq(0)
            end
          end

          context "when the notification belongs to group and has group members with different notifier from the owner's" do
            it "returns 0" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              expect(group_member.group_member_notifier_count).to eq(0)
              expect(group_member.group_notifier_count).to eq(0)
            end
          end
        end
      end

      context "for opened notification" do
        context "as default" do
          context "with notifier" do
            before do
              test_instance.update(notifier: create(:user))
            end

            context "when the notification is group owner and has group members with the same notifier with the owner's" do
              it "returns 0" do
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                test_instance.open!
                expect(test_instance.group_member_notifier_count).to eq(0)
              end
            end

            context "when the notification is group owner and has group members with different notifier from the owner's" do
              it "returns member notifier count" do
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                test_instance.open!
                expect(test_instance.group_member_notifier_count).to eq(2)
              end

              it "returns member notifier count with selecting distinct notifier" do
                group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                               create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: group_member.notifier)
                test_instance.open!
                expect(test_instance.group_member_notifier_count).to eq(1)
              end
            end

            context "when the notification belongs to group and has group members with the same notifier with the owner's" do
              it "returns 0" do
                group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                               create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                test_instance.open!
                expect(group_member.group_member_notifier_count).to eq(0)
              end
            end

            context "when the notification belongs to group and has group members with different notifier from the owner's" do
              it "returns member notifier count" do
                group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                               create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                test_instance.open!
                expect(group_member.group_member_notifier_count).to eq(2)
              end

              it "returns member notifier count with selecting distinct notifier" do
                group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                               create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: group_member.notifier)
                test_instance.open!
                expect(group_member.group_member_notifier_count).to eq(1)
              end
            end
          end

          context "without notifier" do
            before do
              test_instance.update(notifier: nil)
            end

            context "when the notification is group owner and has no group members" do
              it "returns 0" do
                test_instance.open!
                expect(test_instance.group_member_notifier_count).to eq(0)
              end
            end

            context "when the notification is group owner and has group members with the same notifier with the owner's" do
              it "returns 0" do
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                test_instance.open!
                expect(test_instance.group_member_notifier_count).to eq(0)
              end
            end

            context "when the notification is group owner and has group members with different notifier from the owner's" do
              it "returns 0" do
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                test_instance.open!
                expect(test_instance.group_member_notifier_count).to eq(0)
              end
            end

            context "when the notification belongs to group and has group members with the same notifier with the owner's" do
              it "returns 0" do
                group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                               create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: test_instance.notifier)
                test_instance.open!
                expect(group_member.group_member_notifier_count).to eq(0)
              end
            end

            context "when the notification belongs to group and has group members with different notifier from the owner's" do
              it "returns 0" do
                group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                               create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                test_instance.open!
                expect(group_member.group_member_notifier_count).to eq(0)
              end
            end
          end
        end

        context "with limit" do
          before do
            test_instance.update(notifier: create(:user))
          end

          context "when the notification is group owner and has group members with different notifier from the owner's" do
            it "returns member notifier count by limit" do
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              test_instance.open!
              expect(test_instance.group_member_notifier_count(0)).to eq(0)
            end
          end

          context "when the notification belongs to group and has group members with different notifier from the owner's" do
            it "returns member count by limit" do
              group_member = create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
                             create(test_class_name, target: test_instance.target, group_owner: test_instance, notifier: create(:user))
              test_instance.open!
              expect(group_member.group_member_notifier_count(0)).to eq(0)
            end
          end
        end
      end
    end

    describe "#latest_group_member" do
      context "with group member" do
        it "returns latest group member" do
          member1 = create(test_class_name, target: test_instance.target, group_owner: test_instance)
          member2 = create(test_class_name, target: test_instance.target, group_owner: test_instance, created_at: member1.created_at + 10.second)
          expect(test_instance.latest_group_member.becomes(ActivityNotification::Notification)).to eq(member2)
        end
      end

      context "without group members" do
        it "returns group owner self" do
          expect(test_instance.latest_group_member).to eq(test_instance)
        end
      end
    end

    describe "#remove_from_group" do
      before do
        @member1 = create(test_class_name, target: test_instance.target, group_owner: test_instance)
        @member2 = create(test_class_name, target: test_instance.target, group_owner: test_instance)
        expect(test_instance.group_member_count).to eq(2)
        expect(@member1.group_owner?).to            be_falsey
      end

      it "removes from notification group" do
        test_instance.remove_from_group
        expect(test_instance.group_member_count).to eq(0)
      end

      it "makes a new group owner" do
        test_instance.remove_from_group
        expect(@member1.reload.group_owner?).to                                             be_truthy
        expect(@member1.group_members.size).to                                              eq(1)
        expect(@member1.group_members.first.becomes(ActivityNotification::Notification)).to eq(@member2)
      end

      it "returns new group owner instance" do
        expect(test_instance.remove_from_group.becomes(ActivityNotification::Notification)).to eq(@member1)
      end
    end

    describe "#notifiable_path" do
      it "returns notifiable.notifiable_path" do
        expect(test_instance.notifiable_path)
          .to eq(test_instance.notifiable.notifiable_path(test_instance.target_type, test_instance.key))
      end
    end

    describe "#subscribed?" do
      it "returns target.subscribes_to_notification?" do
        expect(test_instance.subscribed?)
          .to eq(test_instance.target.subscribes_to_notification?(test_instance.key))
      end
    end

    describe "#email_subscribed?" do
      it "returns target.subscribes_to_notification_email?" do
        expect(test_instance.subscribed?)
          .to eq(test_instance.target.subscribes_to_notification_email?(test_instance.key))
      end
    end

    describe "#optional_target_subscribed?" do
      it "returns target.subscribes_to_optional_target?" do
        test_instance.target.create_subscription(key: test_instance.key, optional_targets: { subscribing_to_console_output: false })
        expect(test_instance.optional_target_subscribed?(:console_output)).to be_falsey
        expect(test_instance.optional_target_subscribed?(:console_output))
          .to eq(test_instance.target.subscribes_to_optional_target?(test_instance.key, :console_output))
      end
    end

    describe "#optional_targets" do
      it "returns notifiable.optional_targets" do
        require 'custom_optional_targets/console_output'
        @optional_target = CustomOptionalTarget::ConsoleOutput.new
        notifiable_class.acts_as_notifiable test_instance.target.to_resources_name.to_sym, optional_targets: ->{ [@optional_target] }
        expect(test_instance.optional_targets).to eq([@optional_target])
        expect(test_instance.optional_targets)
          .to eq(test_instance.notifiable.optional_targets(test_instance.target.to_resources_name, test_instance.key))
      end
    end

    describe "#optional_target_names" do
      it "returns notifiable.optional_target_names" do
        require 'custom_optional_targets/console_output'
        @optional_target = CustomOptionalTarget::ConsoleOutput.new
        notifiable_class.acts_as_notifiable test_instance.target.to_resources_name.to_sym, optional_targets: ->{ [@optional_target] }
        expect(test_instance.optional_target_names).to eq([:console_output])
        expect(test_instance.optional_target_names)
          .to eq(test_instance.notifiable.optional_target_names(test_instance.target.to_resources_name, test_instance.key))
      end
    end
  end

  describe "as protected instance methods" do
    describe "#unopened_group_member_count" do
      it "is defined as protected method" do
        expect(test_instance.respond_to?(:unopened_group_member_count)).to       be_falsey
        expect(test_instance.respond_to?(:unopened_group_member_count, true)).to be_truthy
      end
    end

    describe "#opened_group_member_count" do
      it "is defined as protected method" do
        expect(test_instance.respond_to?(:opened_group_member_count)).to       be_falsey
        expect(test_instance.respond_to?(:opened_group_member_count, true)).to be_truthy
      end
    end

    describe "#unopened_group_member_notifier_count" do
      it "is defined as protected method" do
        expect(test_instance.respond_to?(:unopened_group_member_notifier_count)).to       be_falsey
        expect(test_instance.respond_to?(:unopened_group_member_notifier_count, true)).to be_truthy
      end
    end

    describe "#opened_group_member_notifier_count" do
      it "is defined as protected method" do
        expect(test_instance.respond_to?(:opened_group_member_notifier_count)).to       be_falsey
        expect(test_instance.respond_to?(:opened_group_member_notifier_count, true)).to be_truthy
      end
    end
  end

  private
    def validate_expected_notification(notification, target, notifiable)
      expect(notification).to be_a described_class
      expect(notification.target).to eq(target)
      expect(notification.notifiable).to eq(notifiable)
    end

end