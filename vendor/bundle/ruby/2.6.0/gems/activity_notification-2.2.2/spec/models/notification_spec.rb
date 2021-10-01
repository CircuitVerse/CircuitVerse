# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/apis/notification_api_spec.rb').to_s
# require Rails.root.join('../../spec/concerns/renderable_spec.rb').to_s

describe ActivityNotification::Notification, type: :model do

  it_behaves_like :notification_api
  it_behaves_like :renderable

  describe "with association" do
    context "belongs to target" do
      before do
        @target = create(:confirmed_user)
        @notification = create(:notification, target: @target)
      end

      it "responds to target" do
        expect(@notification.reload.target).to eq(@target)
      end

      it "responds to target_id" do
        expect(@notification.reload.target_id.to_s).to eq(@target.id.to_s)
      end

      it "responds to target_type" do
        expect(@notification.reload.target_type).to eq("User")
      end
    end

    it "belongs to notifiable" do
      notifiable = create(:article)
      notification = create(:notification, notifiable: notifiable)
      expect(notification.reload.notifiable).to eq(notifiable)
    end

    it "belongs to group" do
      group = create(:article)
      notification = create(:notification, group: group)
      expect(notification.reload.group).to eq(group)
    end

    it "belongs to notification as group_owner" do
      group_owner  = create(:notification, group_owner: nil)
      group_member = create(:notification, group_owner: group_owner)
      expect(group_member.reload.group_owner.becomes(ActivityNotification::Notification)).to eq(group_owner)
    end

    it "has many notifications as group_members" do
      group_owner  = create(:notification, group_owner: nil)
      group_member = create(:notification, group_owner: group_owner)
      expect(group_owner.reload.group_members.first.becomes(ActivityNotification::Notification)).to eq(group_member)
    end

    it "belongs to notifier" do
      notifier = create(:confirmed_user)
      notification = create(:notification, notifier: notifier)
      expect(notification.reload.notifier).to eq(notifier)
    end

    context "returns as_json including associated models" do
      it "returns as_json with include option as Symbol" do
        notification = create(:notification)
        expect(notification.as_json(include: :target)["target"]["id"].to_s).to eq(notification.target.id.to_s)
      end

      it "returns as_json with include option as Array" do
        notification = create(:notification)
        expect(notification.as_json(include: [:target])["target"]["id"].to_s).to eq(notification.target.id.to_s)
      end

      it "returns as_json with include option as Hash" do
        notification = create(:notification)
        expect(notification.as_json(include: { target: { methods: [:printable_target_name] } })["target"]["id"].to_s).to eq(notification.target.id.to_s)
      end
    end
  end

  describe "with serializable column" do
    it "has parameters for hash with symbol" do
      parameters = {a: 1, b: 2, c: 3}
      notification = create(:notification, parameters: parameters)
      expect(notification.reload.parameters.symbolize_keys).to eq(parameters)
    end

    it "has parameters for hash with string" do
      parameters = {'a' => 1, 'b' => 2, 'c' => 3}
      notification = create(:notification, parameters: parameters)
      expect(notification.reload.parameters.stringify_keys).to eq(parameters)
    end
  end

  describe "with validation" do
    before { @notification = build(:notification) }

    it "is valid with target, notifiable and key" do
      expect(@notification).to be_valid
    end

    it "is invalid with blank target" do
      @notification.target = nil
      expect(@notification).to be_invalid
      expect(@notification.errors[:target]).not_to be_empty
    end

    it "is invalid with blank notifiable" do
      @notification.notifiable = nil
      expect(@notification).to be_invalid
      expect(@notification.errors[:notifiable]).not_to be_empty
    end

    it "is invalid with blank key" do
      @notification.key = nil
      expect(@notification).to be_invalid
      expect(@notification.errors[:key]).not_to be_empty
    end
  end

  describe "with scope" do
    context "to filter by notification status" do
      before do
        ActivityNotification::Notification.delete_all
        @unopened_group_owner  = create(:notification, group_owner: nil)
        @unopened_group_member = create(:notification, group_owner: @unopened_group_owner)
        @opened_group_owner    = create(:notification, group_owner: nil, opened_at: Time.current)
        @opened_group_member   = create(:notification, group_owner: @opened_group_owner, opened_at: Time.current)
      end

      it "works with group_owners_only scope" do
        notifications = ActivityNotification::Notification.group_owners_only
        expect(notifications.to_a.size).to eq(2)
        expect(notifications.unopened_only.first).to eq(@unopened_group_owner)
        expect(notifications.opened_only!.first).to eq(@opened_group_owner)
      end

      it "works with group_members_only scope" do
        notifications = ActivityNotification::Notification.group_members_only
        expect(notifications.to_a.size).to eq(2)
        expect(notifications.unopened_only.first).to eq(@unopened_group_member)
        expect(notifications.opened_only!.first).to eq(@opened_group_member)
      end

      it "works with unopened_only scope" do
        notifications = ActivityNotification::Notification.unopened_only
        expect(notifications.to_a.size).to eq(2)
        expect(notifications.group_owners_only.first).to eq(@unopened_group_owner)
        expect(notifications.group_members_only.first).to eq(@unopened_group_member)
      end

      it "works with unopened_index scope" do
        notifications = ActivityNotification::Notification.unopened_index
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@unopened_group_owner)
      end

      it "works with opened_only! scope" do
        notifications = ActivityNotification::Notification.opened_only!
        expect(notifications.to_a.size).to eq(2)
        expect(notifications.group_owners_only.first).to eq(@opened_group_owner)
        expect(notifications.group_members_only.first).to eq(@opened_group_member)
      end

      context "with opened_only scope" do
        it "works" do
          notifications = ActivityNotification::Notification.opened_only(4)
          expect(notifications.to_a.size).to eq(2)
          expect(notifications.group_owners_only.first).to eq(@opened_group_owner)
          expect(notifications.group_members_only.first).to eq(@opened_group_member)
        end

        it "works with limit" do
          notifications = ActivityNotification::Notification.opened_only(1)
          expect(notifications.to_a.size).to eq(1)
        end
      end

      context "with opened_index scope" do
        it "works" do
          notifications = ActivityNotification::Notification.opened_index(4)
          expect(notifications.to_a.size).to eq(1)
          expect(notifications.first).to eq(@opened_group_owner)
        end

        it "works with limit" do
          notifications = ActivityNotification::Notification.opened_index(0)
          expect(notifications.to_a.size).to eq(0)
        end
      end

      it "works with unopened_index_group_members_only scope" do
        notifications = ActivityNotification::Notification.unopened_index_group_members_only
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@unopened_group_member)
      end

      context "with opened_index_group_members_only scope" do
        it "works" do
          notifications = ActivityNotification::Notification.opened_index_group_members_only(4)
          expect(notifications.to_a.size).to eq(1)
          expect(notifications.first).to eq(@opened_group_member)
        end

        it "works with limit" do
          notifications = ActivityNotification::Notification.opened_index_group_members_only(0)
          expect(notifications.to_a.size).to eq(0)
        end
      end
    end

    context "to filter by association" do
      before do
        ActivityNotification::Notification.delete_all
        @target_1, @notifiable_1, @group_1, @key_1 = create(:confirmed_user), create(:article), nil,           "key.1"
        @target_2, @notifiable_2, @group_2, @key_2 = create(:confirmed_user), create(:comment), @notifiable_1, "key.2"
        @notification_1 = create(:notification, target: @target_1, notifiable: @notifiable_1, group: @group_1, key: @key_1)
        @notification_2 = create(:notification, target: @target_2, notifiable: @notifiable_2, group: @group_2, key: @key_2)
      end

      it "works with filtered_by_target scope" do
        notifications = ActivityNotification::Notification.filtered_by_target(@target_1)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_1)
        notifications = ActivityNotification::Notification.filtered_by_target(@target_2)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_2)
      end

      it "works with filtered_by_instance scope" do
        notifications = ActivityNotification::Notification.filtered_by_instance(@notifiable_1)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_1)
        notifications = ActivityNotification::Notification.filtered_by_instance(@notifiable_2)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_2)
      end

      it "works with filtered_by_type scope" do
        notifications = ActivityNotification::Notification.filtered_by_type(@notifiable_1.to_class_name)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_1)
        notifications = ActivityNotification::Notification.filtered_by_type(@notifiable_2.to_class_name)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_2)
      end

      it "works with filtered_by_group scope" do
        notifications = ActivityNotification::Notification.filtered_by_group(@group_1)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_1)
        notifications = ActivityNotification::Notification.filtered_by_group(@group_2)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_2)
      end

      it "works with filtered_by_key scope" do
        notifications = ActivityNotification::Notification.filtered_by_key(@key_1)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_1)
        notifications = ActivityNotification::Notification.filtered_by_key(@key_2)
        expect(notifications.to_a.size).to eq(1)
        expect(notifications.first).to eq(@notification_2)
      end

      describe 'filtered_by_options scope' do
        context 'with filtered_by_type options' do
          it "works with filtered_by_options scope" do
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_type: @notifiable_1.to_class_name })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_1)
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_type: @notifiable_2.to_class_name })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_2)
          end
        end

        context 'with filtered_by_group options' do
          it "works with filtered_by_options scope" do
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_group: @group_1 })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_1)
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_group: @group_2 })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_2)
          end
        end

        context 'with filtered_by_group_type and :filtered_by_group_id options' do
          it "works with filtered_by_options scope" do
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_group_type: 'Article', filtered_by_group_id: @group_2.id.to_s })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_2)
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_group_type: 'Article' })
            expect(notifications.to_a.size).to eq(2)
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_group_id: @group_2.id.to_s })
            expect(notifications.to_a.size).to eq(2)
          end
        end

        context 'with filtered_by_key options' do
          it "works with filtered_by_options scope" do
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_key: @key_1 })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_1)
            notifications = ActivityNotification::Notification.filtered_by_options({ filtered_by_key: @key_2 })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_2)
          end
        end

        context 'with custom_filter options' do
          it "works with filtered_by_options scope" do
            notifications = ActivityNotification::Notification.filtered_by_options({ custom_filter: { key: @key_2 } })
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_2)
          end

          it "works with filtered_by_options scope with filter depending on ORM" do
            options =
              case ActivityNotification.config.orm
              when :active_record then { custom_filter: ["notifications.key = ?", @key_1] }
              when :mongoid       then { custom_filter: { key: {'$eq': @key_1} } }
              when :dynamoid      then { custom_filter: {'key.begins_with': @key_1} }
              end
            notifications = ActivityNotification::Notification.filtered_by_options(options)
            expect(notifications.to_a.size).to eq(1)
            expect(notifications.first).to eq(@notification_1)
          end
        end

        context 'with no options' do
          it "works with filtered_by_options scope" do
            notifications = ActivityNotification::Notification.filtered_by_options
            expect(notifications.to_a.size).to eq(2)
          end
        end
      end
    end

    context "to make order by created_at" do
      before do
        ActivityNotification::Notification.delete_all
        @target = create(:confirmed_user)
        unopened_group_owner   = create(:notification, target: @target, group_owner: nil)
        unopened_group_member  = create(:notification, target: @target, group_owner: unopened_group_owner, created_at: unopened_group_owner.created_at + 10.second)
        opened_group_owner     = create(:notification, target: @target, group_owner: nil, opened_at: Time.current, created_at: unopened_group_owner.created_at + 20.second)
        opened_group_member    = create(:notification, target: @target, group_owner: opened_group_owner, opened_at: Time.current, created_at: unopened_group_owner.created_at + 30.second)
        @earliest_notification = unopened_group_owner
        @latest_notification   = opened_group_member
      end

      unless ActivityNotification.config.orm == :dynamoid
        context "using ORM other than dynamoid, you can directly call latest/earliest order method from class objects" do

          it "works with latest_order scope" do
            notifications = ActivityNotification::Notification.latest_order
            expect(notifications.to_a.size).to eq(4)
            expect(notifications.first).to eq(@latest_notification)
            expect(notifications.last).to eq(@earliest_notification)
          end

          it "works with earliest_order scope" do
            notifications = ActivityNotification::Notification.earliest_order
            expect(notifications.to_a.size).to eq(4)
            expect(notifications.first).to eq(@earliest_notification)
            expect(notifications.last).to eq(@latest_notification)
          end

          it "returns the latest notification with latest scope" do
            notification = ActivityNotification::Notification.latest
            expect(notification).to eq(@latest_notification)
          end

          it "returns the earliest notification with earliest scope" do
            notification = ActivityNotification::Notification.earliest
            expect(notification).to eq(@earliest_notification)
          end

        end
      else
        context "using dynamoid, you can call latest/earliest order method only with query using partition key of Global Secondary Index" do

          it "works with latest_order scope" do
            notifications = ActivityNotification::Notification.filtered_by_target(@target).latest_order
            expect(notifications.to_a.size).to eq(4)
            expect(notifications.first).to eq(@latest_notification)
            expect(notifications.last).to eq(@earliest_notification)
          end

          it "works with earliest_order scope" do
            notifications = ActivityNotification::Notification.filtered_by_target(@target).earliest_order
            expect(notifications.to_a.size).to eq(4)
            expect(notifications.first).to eq(@earliest_notification)
            expect(notifications.last).to eq(@latest_notification)
          end

          it "returns the latest notification with latest scope" do
            notification = ActivityNotification::Notification.filtered_by_target(@target).latest
            expect(notification).to eq(@latest_notification)
          end

          it "returns the earliest notification with earliest scope" do
            notification = ActivityNotification::Notification.filtered_by_target(@target).earliest
            expect(notification).to eq(@earliest_notification)
          end

        end
      end

      it "works with latest_order! scope" do
        notifications = ActivityNotification::Notification.latest_order!
        expect(notifications.to_a.size).to eq(4)
        expect(notifications.first).to eq(@latest_notification)
        expect(notifications.last).to eq(@earliest_notification)
      end

      it "works with latest_order!(reverse=true) scope" do
        notifications = ActivityNotification::Notification.latest_order!(true)
        expect(notifications.to_a.size).to eq(4)
        expect(notifications.first).to eq(@earliest_notification)
        expect(notifications.last).to eq(@latest_notification)
      end

      it "works with earliest_order! scope" do
        notifications = ActivityNotification::Notification.earliest_order!
        expect(notifications.to_a.size).to eq(4)
        expect(notifications.first).to eq(@earliest_notification)
        expect(notifications.last).to eq(@latest_notification)
      end

      it "returns the latest notification with latest! scope" do
        notification = ActivityNotification::Notification.latest!
        expect(notification).to eq(@latest_notification)
      end

      it "returns the earliest notification with earliest! scope" do
        notification = ActivityNotification::Notification.earliest!
        expect(notification).to eq(@earliest_notification)
      end
    end

    context "to include with associated records" do
      before do
        ActivityNotification::Notification.delete_all
        create(:notification)
        @notifications = ActivityNotification::Notification.filtered_by_key("default.default")
      end

      it "works with_target" do
        expect(@notifications.with_target.count).to        eq(1)
      end

      it "works with_notifiable" do
        expect(@notifications.with_notifiable.count).to    eq(1)
      end

      it "works with_group" do
        expect(@notifications.with_group.count).to         eq(1)
      end

      it "works with_group_owner" do
        expect(@notifications.with_group_owner.count).to   eq(1)
      end

      it "works with_group_members" do
        expect(@notifications.with_group_members.count).to eq(1)
      end

      it "works with_notifier" do
        expect(@notifications.with_notifier.count).to      eq(1)
      end
    end
  end
end
