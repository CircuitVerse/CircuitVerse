describe ActivityNotification::ActsAsNotifiable do
  include ActiveJob::TestHelper
  let(:dummy_model_class)      { Dummy::DummyBase }
  let(:dummy_notifiable_class) { Dummy::DummyNotifiable }
  let(:user_target)            { create(:confirmed_user) }
  let(:dummy_target)           { create(:dummy_target) }

  describe "as public class methods" do
    describe ".acts_as_notifiable" do
      before do
        dummy_notifiable_class.set_notifiable_class_defaults
        dummy_notifiable_class.reset_callbacks :create
        dummy_notifiable_class.reset_callbacks :update
        dummy_notifiable_class.reset_callbacks :destroy
        dummy_notifiable_class.reset_callbacks :commit if dummy_notifiable_class.respond_to? :after_commit
        @notifiable = dummy_notifiable_class.create
      end

      it "have not included Notifiable before calling" do
        expect(dummy_model_class.respond_to?(:available_as_notifiable?)).to be_falsey
      end

      it "includes Notifiable" do
        dummy_model_class.acts_as_notifiable :users
        expect(dummy_model_class.respond_to?(:available_as_notifiable?)).to be_truthy
        expect(dummy_model_class.available_as_notifiable?).to be_truthy
      end

      context "with no options" do
        it "returns hash of specified options" do
          expect(dummy_model_class.acts_as_notifiable :users).to eq({})
        end
      end

      context "with :tracked option" do
        before do
          user_target.notifications.delete_all
          expect(user_target.notifications.count).to eq(0)
        end

        it "returns hash of :tracked option" do
          expect(dummy_notifiable_class.acts_as_notifiable :users, tracked: true)
            .to eq({ tracked: [:create, :update] })
        end

        context "without option" do
          it "does not generate notifications when notifiable is created and updated" do
            dummy_notifiable_class.acts_as_notifiable :users, targets: [user_target]
            notifiable = dummy_notifiable_class.create
            notifiable.update(created_at: notifiable.updated_at)
            expect(user_target.notifications.filtered_by_instance(notifiable).count).to eq(0)
          end
        end

        context "true as :tracked" do
          before do
            dummy_notifiable_class.acts_as_notifiable :users, targets: [user_target], tracked: true, notifiable_path: -> { "dummy_path" }
            @created_notifiable = dummy_notifiable_class.create
          end

          context "creation" do
            it "generates notifications when notifiable is created" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
            end

            it "generated notification has notification_key_for_tracked_creation as key" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).latest.key)
                .to eq(@created_notifiable.notification_key_for_tracked_creation)
            end
          end

          context "update" do
            before do
              user_target.notifications.delete_all
              expect(user_target.notifications.count).to eq(0)
              @notifiable.update(created_at: @notifiable.updated_at)
            end

            it "generates notifications when notifiable is updated" do
              expect(user_target.notifications.filtered_by_instance(@notifiable).count).to eq(1)
            end

            it "generated notification has notification_key_for_tracked_update as key" do
              expect(user_target.notifications.filtered_by_instance(@notifiable).first.key)
                .to eq(@notifiable.notification_key_for_tracked_update)
            end
          end

          context "when the target is also configured as notifiable" do
            before do
              ActivityNotification::Notification.filtered_by_type("Dummy::DummyNotifiableTarget").delete_all
              Dummy::DummyNotifiableTarget.delete_all
              @created_target = Dummy::DummyNotifiableTarget.create
              @created_notifiable = Dummy::DummyNotifiableTarget.create
            end

            it "generates notifications to specified targets" do
              expect(@created_target.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
              expect(@created_notifiable.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
            end
          end
        end

        context "with :only option (creation only)" do
          before do
            dummy_notifiable_class.acts_as_notifiable :users, targets: [user_target], tracked: { only: [:create] }, notifiable_path: -> { "dummy_path" }
            @created_notifiable = dummy_notifiable_class.create
          end

          context "creation" do
            it "generates notifications when notifiable is created" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
            end

            it "generated notification has notification_key_for_tracked_creation as key" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).latest.key)
                .to eq(@created_notifiable.notification_key_for_tracked_creation)
            end
          end

          context "update" do
            before do
              user_target.notifications.delete_all
              expect(user_target.notifications.count).to eq(0)
              @notifiable.update(created_at: @notifiable.updated_at)
            end

            it "does not generate notifications when notifiable is updated" do
              expect(user_target.notifications.filtered_by_instance(@notifiable).count).to eq(0)
            end
          end
        end

        context "with :except option (except update)" do
          before do
            dummy_notifiable_class.acts_as_notifiable :users, targets: [user_target], tracked: { except: [:update] }, notifiable_path: -> { "dummy_path" }
            @created_notifiable = dummy_notifiable_class.create
          end

          context "creation" do
            it "generates notifications when notifiable is created" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
            end

            it "generated notification has notification_key_for_tracked_creation as key" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).latest.key)
                .to eq(@created_notifiable.notification_key_for_tracked_creation)
            end
          end

          context "update" do
            before do
              user_target.notifications.delete_all
              expect(user_target.notifications.count).to eq(0)
              @notifiable.update(created_at: @notifiable.updated_at)
            end

            it "does not generate notifications when notifiable is updated" do
              expect(user_target.notifications.filtered_by_instance(@notifiable).count).to eq(0)
            end
          end
        end

        context "with :key option" do
          before do
            dummy_notifiable_class.acts_as_notifiable :users, targets: [user_target], tracked: { key: "test.key" }, notifiable_path: -> { "dummy_path" }
            @created_notifiable = dummy_notifiable_class.create
          end

          context "creation" do
            it "generates notifications when notifiable is created" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
            end

            it "generated notification has specified key" do
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).latest.key)
                .to eq("test.key")
            end
          end

          context "update" do
            before do
              user_target.notifications.delete_all
              expect(user_target.notifications.count).to eq(0)
              @notifiable.update(created_at: @notifiable.updated_at)
            end

            it "generates notifications when notifiable is updated" do
              expect(user_target.notifications.filtered_by_instance(@notifiable).count).to eq(1)
            end

            it "generated notification has notification_key_for_tracked_update as key" do
              expect(user_target.notifications.filtered_by_instance(@notifiable).first.key)
                .to eq("test.key")
            end
          end
        end

        context "with :notify_later option" do
          before do
            ActiveJob::Base.queue_adapter = :test
            dummy_notifiable_class.acts_as_notifiable :users, targets: [user_target], tracked: { notify_later: true }, notifiable_path: -> { "dummy_path" }
            @created_notifiable = dummy_notifiable_class.create
          end

          context "creation" do
            it "generates notifications later when notifiable is created" do
              expect {
                @created_notifiable = dummy_notifiable_class.create
              }.to have_enqueued_job(ActivityNotification::NotifyJob)
            end

            it "creates notification records later when notifiable is created" do
              perform_enqueued_jobs do
                @created_notifiable = dummy_notifiable_class.create
              end
              expect(user_target.notifications.filtered_by_instance(@created_notifiable).count).to eq(1)
            end
          end

          context "update" do
            before do
              user_target.notifications.delete_all
              expect(user_target.notifications.count).to eq(0)
              @notifiable.update(created_at: @notifiable.updated_at)
            end

            it "generates notifications later when notifiable is created" do
              expect {
                @notifiable.update(created_at: @notifiable.updated_at)
              }.to have_enqueued_job(ActivityNotification::NotifyJob)
            end

            it "creates notification records later when notifiable is created" do
              perform_enqueued_jobs do
                @notifiable.update(created_at: @notifiable.updated_at)
              end
              expect(user_target.notifications.filtered_by_instance(@notifiable).count).to eq(1)
            end
          end
        end
      end

      context "with :dependent_notifications option" do
        before do
          dummy_notifiable_class.delete_all
          @notifiable_1, @notifiable_2, @notifiable_3 = dummy_notifiable_class.create, dummy_notifiable_class.create, dummy_notifiable_class.create
          @group_owner  = create(:notification, target: user_target, notifiable: @notifiable_1, group: @notifiable_1)
          @group_member = create(:notification, target: user_target, notifiable: @notifiable_2, group: @notifiable_1, group_owner: @group_owner)
                          create(:notification, target: user_target, notifiable: @notifiable_3, group: @notifiable_1, group_owner: @group_owner, created_at: @group_member.created_at + 10.second)
          @other_target_group_owner  = create(:notification, target: dummy_target, notifiable: @notifiable_1, group: @notifiable_1)
          @other_target_group_member = create(:notification, target: dummy_target, notifiable: @notifiable_2, group: @notifiable_1, group_owner: @other_target_group_owner)
                                       create(:notification, target: dummy_target, notifiable: @notifiable_3, group: @notifiable_1, group_owner: @other_target_group_owner)
          expect(@group_owner.group_member_count).to eq(2)
          expect(@other_target_group_owner.group_member_count).to eq(2)
          expect(user_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(1)
          expect(dummy_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(1)
        end

        it "returns hash of :dependent_notifications option" do
          expect(dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :restrict_with_exception)
            .to eq({ dependent_notifications: :restrict_with_exception })
        end

        context "without option" do
          it "does not deletes any notifications when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users
            expect(user_target.notifications.reload.size).to eq(3)
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.reload.size).to eq(3)
          end
        end

        context ":delete_all" do
          it "deletes all notifications when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :delete_all
            expect(user_target.notifications.reload.size).to eq(3)
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.reload.size).to eq(2)
            expect(@group_member.reload.group_owner?).to be_falsey
          end

          it "does not delete notifications of other targets when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :delete_all
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(0)
            expect(dummy_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(1)
          end
        end

        context ":destroy" do
          it "destroies all notifications when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :destroy
            expect(user_target.notifications.reload.size).to eq(3)
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.reload.size).to eq(2)
            expect(@group_member.reload.group_owner?).to be_falsey
          end

          it "does not destroy notifications of other targets when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :destroy
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(0)
            expect(dummy_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(1)
          end
        end

        context ":restrict_with_exception" do
          it "can not be deleted when it has generated notifications" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :restrict_with_exception
            expect(user_target.notifications.reload.size).to eq(3)
            if ActivityNotification.config.orm == :active_record
              expect { @notifiable_1.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
            else
              expect { @notifiable_1.destroy }.to raise_error(ActivityNotification::DeleteRestrictionError)
            end
          end
        end

        context ":restrict_with_error" do
          it "can not be deleted when it has generated notifications" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :restrict_with_error
            expect(user_target.notifications.reload.size).to eq(3)
            @notifiable_1.destroy
            expect(@notifiable_1.destroyed?).to be_falsey
          end
        end

        context ":update_group_and_delete_all" do
          it "deletes all notifications and update notification group when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :update_group_and_delete_all
            expect(user_target.notifications.reload.size).to eq(3)
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.reload.size).to eq(2)
            expect(@group_member.reload.group_owner?).to be_truthy
          end

          it "does not delete notifications of other targets when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :update_group_and_delete_all
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(0)
            expect(dummy_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(1)
          end

          it "does not update notification group when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :update_group_and_delete_all
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(@group_member.reload.group_owner?).to be_truthy
            expect(@other_target_group_member.reload.group_owner?).to be_falsey
          end
        end

        context ":update_group_and_destroy" do
          it "destroies all notifications and update notification group when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :update_group_and_destroy
            expect(user_target.notifications.reload.size).to eq(3)
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.reload.size).to eq(2)
            expect(@group_member.reload.group_owner?).to be_truthy
          end

          it "does not destroy notifications of other targets when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :update_group_and_destroy
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(user_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(0)
            expect(dummy_target.notifications.filtered_by_instance(@notifiable_1).count).to eq(1)
          end

          it "does not update notification group when notifiable is deleted" do
            dummy_notifiable_class.acts_as_notifiable :users, dependent_notifications: :update_group_and_destroy
            expect { @notifiable_1.destroy }.to change(@notifiable_1, :destroyed?).from(false).to(true)
            expect(@group_member.reload.group_owner?).to be_truthy
            expect(@other_target_group_member.reload.group_owner?).to be_falsey
          end
        end
      end

      context "with :optional_targets option" do
        require 'custom_optional_targets/console_output'
        require 'custom_optional_targets/wrong_target'

        it "returns hash of :optional_targets option" do
          result_hash = dummy_notifiable_class.acts_as_notifiable :users, optional_targets: { CustomOptionalTarget::ConsoleOutput => {} }
          expect(result_hash).to be_a(Hash)
          expect(result_hash[:optional_targets]).to       be_a(Array)
          expect(result_hash[:optional_targets].first).to be_a(CustomOptionalTarget::ConsoleOutput)
        end

        context "without option" do
          it "does not configure optional_targets and notifiable#optional_targets returns empty array" do
            dummy_notifiable_class.acts_as_notifiable :users
            expect(@notifiable.optional_targets(:users)).to eq([])
          end
        end

        context "with hash configuration" do
          it "configure optional_targets and notifiable#optional_targets returns optional_target array" do
            dummy_notifiable_class.acts_as_notifiable :users, optional_targets: { CustomOptionalTarget::ConsoleOutput => {} }
            expect(@notifiable.optional_targets(:users)).to       be_a(Array)
            expect(@notifiable.optional_targets(:users).first).to be_a(CustomOptionalTarget::ConsoleOutput)
          end
        end

        context "with hash configuration but specified class does not extends ActivityNotification::OptionalTarget::Base" do
          it "raise TypeError" do
            expect { dummy_notifiable_class.acts_as_notifiable :users, optional_targets: { CustomOptionalTarget::WrongTarget => {} } }
              .to raise_error(TypeError, /.+ is not a kind of ActivityNotification::OptionalTarget::Base/)
          end
        end

        context "with lambda function configuration" do
          it "configure optional_targets and notifiable#optional_targets returns optional_target array" do
            module AdditionalMethods
              require 'custom_optional_targets/console_output'
            end
            dummy_notifiable_class.extend(AdditionalMethods)
            dummy_notifiable_class.acts_as_notifiable :users, optional_targets: ->(notifiable, key){ key == 'dummy_key' ? [CustomOptionalTarget::ConsoleOutput.new] : [] }
            expect(@notifiable.optional_targets(:users)).to eq([])
            expect(@notifiable.optional_targets(:users, 'dummy_key').first).to be_a(CustomOptionalTarget::ConsoleOutput)
          end
        end
      end
    end

    describe ".available_notifiable_options" do
      it "returns list of available options in acts_as_notifiable" do
        expect(dummy_model_class.available_notifiable_options)
          .to eq([:targets, :group, :group_expiry_delay, :notifier, :parameters, :email_allowed, :action_cable_allowed, :action_cable_api_allowed, :notifiable_path, :printable_notifiable_name, :printable_name, :dependent_notifications, :optional_targets])
      end
    end
  end
end