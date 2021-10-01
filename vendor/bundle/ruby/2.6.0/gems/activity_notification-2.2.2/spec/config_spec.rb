describe ActivityNotification::Config do
  describe "config.mailer" do
    let(:notification) { create(:notification) }

    context "as default" do
      it "is configured with ActivityNotification::Mailer" do
        expect(ActivityNotification::Mailer).to receive(:send_notification_email).and_call_original
        notification.send_notification_email send_later: false
      end

      it "is not configured with CustomNotificationMailer" do
        expect(CustomNotificationMailer).not_to receive(:send_notification_email).and_call_original
        notification.send_notification_email send_later: false
      end
    end

    context "when it is configured with CustomNotificationMailer" do
      before do
        ActivityNotification.config.mailer = 'CustomNotificationMailer'
        ActivityNotification::Notification.set_notification_mailer
      end

      after do
        ActivityNotification.config.mailer = 'ActivityNotification::Mailer'
        ActivityNotification::Notification.set_notification_mailer
      end

      it "is configured with CustomMailer" do
        expect(CustomNotificationMailer).to receive(:send_notification_email).and_call_original
        notification.send_notification_email send_later: false
      end
    end
  end

  describe "config.store_with_associated_records" do
    let(:target) { create(:confirmed_user) }

    context "when it is configured as true" do
      if ActivityNotification.config.orm == :active_record
        it "raises ActivityNotification::ConfigError when you use active_record ORM" do
          expect { ActivityNotification.config.store_with_associated_records = true }.to raise_error(ActivityNotification::ConfigError)
        end
      else
        before do
          @original = ActivityNotification.config.store_with_associated_records
          ActivityNotification.config.store_with_associated_records = true
          load Rails.root.join("../../lib/activity_notification/orm/#{ActivityNotification.config.orm}/notification.rb").to_s
          @notification = create(:notification, target: target)
        end

        after do
          ActivityNotification.config.store_with_associated_records = @original
          load Rails.root.join("../../lib/activity_notification/orm/#{ActivityNotification.config.orm}/notification.rb").to_s
        end

        it "stores notification with associated records" do
          expect(@notification.target).to eq(target)
          expect(@notification.stored_target["id"].to_s).to eq(target.id.to_s)
        end
      end
    end

    context "when it is configured as false" do
      before do
        @original = ActivityNotification.config.store_with_associated_records
        ActivityNotification.config.store_with_associated_records = false
        load Rails.root.join("../../lib/activity_notification/orm/#{ActivityNotification.config.orm}/notification.rb").to_s
        @notification = create(:notification, target: target)
      end

      after do
        ActivityNotification.config.store_with_associated_records = @original
        load Rails.root.join("../../lib/activity_notification/orm/#{ActivityNotification.config.orm}/notification.rb").to_s
      end

      it "does not store notification with associated records" do
        expect(@notification.target).to eq(target)
        begin
          expect(@notification.stored_target).to be_nil
        rescue NoMethodError
        end
      end
    end
  end
end
