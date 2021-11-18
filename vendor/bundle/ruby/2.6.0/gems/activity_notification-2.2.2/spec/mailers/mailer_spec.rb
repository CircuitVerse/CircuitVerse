describe ActivityNotification::Mailer do
  include ActiveJob::TestHelper
  let(:notification) { create(:notification) }
  let(:test_target) { notification.target }
  let(:notifications) { [create(:notification, target: test_target), create(:notification, target: test_target)] }
  let(:batch_key) { 'test_batch_key' }

  before do
    ActivityNotification::Mailer.deliveries.clear
    expect(ActivityNotification::Mailer.deliveries.size).to eq(0)
  end

  describe ".send_notification_email" do
    context "with deliver_now" do
      context "as default" do
        before do
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
        end
  
        it "sends notification email now" do
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
        end
  
        it "sends to target email" do
          expect(ActivityNotification::Mailer.deliveries.last.to[0]).to eq(notification.target.email)
        end
  
        it "sends from configured email in initializer" do
          expect(ActivityNotification::Mailer.deliveries.last.from[0])
            .to eq("please-change-me-at-config-initializers-activity_notification@example.com")
        end

        it "sends with default notification subject" do
          expect(ActivityNotification::Mailer.deliveries.last.subject)
            .to eq("Notification of article")
        end
      end

      context "with default from parameter in mailer" do
        it "sends from configured email as default parameter" do
          class CustomMailer < ActivityNotification::Mailer
            default from: "test01@example.com"
          end
          CustomMailer.send_notification_email(notification).deliver_now
          expect(CustomMailer.deliveries.last.from[0])
            .to eq("test01@example.com")
        end
      end

      context "with email value as ActivityNotification.config.mailer_sender" do
        it "sends from configured email as ActivityNotification.config.mailer_sender" do
          ActivityNotification.config.mailer_sender = "test02@example.com"
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.from[0])
            .to eq("test02@example.com")
        end
      end

      context "with email proc as ActivityNotification.config.mailer_sender" do
        it "sends from configured email as ActivityNotification.config.mailer_sender" do
          ActivityNotification.config.mailer_sender =
            ->(key){ key == notification.key ? "test03@example.com" : "test04@example.com" }
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.from[0])
            .to eq("test03@example.com")
        end

        it "sends from configured email as ActivityNotification.config.mailer_sender" do
          ActivityNotification.config.mailer_sender =
            ->(key){ key == 'hogehoge' ? "test03@example.com" : "test04@example.com" }
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.from[0])
            .to eq("test04@example.com")
        end
      end

      context "with defined overriding_notification_email_key in notifiable model" do
        it "sends with configured notification subject in locale file as updated key" do
          module AdditionalMethods
            def overriding_notification_email_key(target, key)
              'comment.reply'
            end
          end
          notification.notifiable.extend(AdditionalMethods)
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.subject)
            .to eq("New comment on your article")
        end
      end

      context "with defined overriding_notification_email_subject in notifiable model" do
        it "sends with updated subject" do
          module AdditionalMethods
            def overriding_notification_email_subject(target, key)
              'Hi, You have got comment'
            end
          end
          notification.notifiable.extend(AdditionalMethods)
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.subject)
            .to eq("Hi, You have got comment")
        end
      end

      context "with defined overriding_notification_email_from in notifiable model" do
        it "sends with updated from" do
          module AdditionalMethods
            def overriding_notification_email_from(target, key)
              'test05@example.com'
            end
          end
          notification.notifiable.extend(AdditionalMethods)
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.from.first)
            .to eq('test05@example.com')
        end
      end

      context "with defined overriding_notification_email_reply_to in notifiable model" do
        it "sends with updated reply_to" do
          module AdditionalMethods
            def overriding_notification_email_reply_to(target, key)
              'test06@example.com'
            end
          end
          notification.notifiable.extend(AdditionalMethods)
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.reply_to.first)
            .to eq('test06@example.com')
        end
      end

      context "with defined overriding_notification_email_message_id in notifiable model" do
        it "sends with specific message id" do
          module AdditionalMethods
            def overriding_notification_email_message_id(target, key)
              "https://www.example.com/test@example.com/"
            end
          end
          notification.notifiable.extend(AdditionalMethods)
          ActivityNotification::Mailer.send_notification_email(notification).deliver_now
          expect(ActivityNotification::Mailer.deliveries.last.message_id)
            .to eq("https://www.example.com/test@example.com/")
        end
      end
      context "when fallback option is :none and the template is missing" do
        it "raise ActionView::MissingTemplate" do
          expect { ActivityNotification::Mailer.send_notification_email(notification, fallback: :none).deliver_now }
            .to raise_error(ActionView::MissingTemplate)
        end
      end
    end

    context "with deliver_later" do
      it "sends notification email later" do
        expect {
          perform_enqueued_jobs do
            ActivityNotification::Mailer.send_notification_email(notification).deliver_later
          end
        }.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
        expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
      end

      it "sends notification email with active job queue" do
        expect {
            ActivityNotification::Mailer.send_notification_email(notification).deliver_later
        }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
      end
    end
  end

  describe ".send_batch_notification_email" do
    context "with deliver_now" do
      context "as default" do
        before do
          ActivityNotification::Mailer.send_batch_notification_email(test_target, notifications, batch_key).deliver_now
        end
  
        it "sends batch notification email now" do
          expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
        end
  
        it "sends to target email" do
          expect(ActivityNotification::Mailer.deliveries.last.to[0]).to eq(test_target.email)
        end
  
      end

      context "when fallback option is :none and the template is missing" do
        it "raise ActionView::MissingTemplate" do
          expect { ActivityNotification::Mailer.send_batch_notification_email(test_target, notifications, batch_key, fallback: :none).deliver_now }
            .to raise_error(ActionView::MissingTemplate)
        end
      end
    end

    context "with deliver_later" do
      it "sends notification email later" do
        expect {
          perform_enqueued_jobs do
            ActivityNotification::Mailer.send_batch_notification_email(test_target, notifications, batch_key).deliver_later
          end
        }.to change { ActivityNotification::Mailer.deliveries.size }.by(1)
        expect(ActivityNotification::Mailer.deliveries.size).to eq(1)
      end

      it "sends notification email with active job queue" do
        expect {
            ActivityNotification::Mailer.send_batch_notification_email(test_target, notifications, batch_key).deliver_later
        }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
      end
    end
  end
end