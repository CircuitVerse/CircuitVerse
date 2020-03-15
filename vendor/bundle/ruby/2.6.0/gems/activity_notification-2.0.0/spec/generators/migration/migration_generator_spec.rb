require 'generators/activity_notification/migration/migration_generator'

describe ActivityNotification::Generators::MigrationGenerator, type: :generator do

  # setup_default_destination
  destination File.expand_path("../../../../tmp", __FILE__)

  before do
    prepare_destination
  end

  after do
    if ActivityNotification.config.orm == :active_record
      ActivityNotification::Notification.reset_column_information
      ActivityNotification::Subscription.reset_column_information
    end
  end

  it 'runs generating migration tasks' do
    gen = generator
    expect(gen).to receive :create_migrations
    gen.invoke_all
  end

  describe 'the generated files' do
    context 'without name argument' do
      before do
        run_generator
      end

      describe 'CreateNotifications migration file' do
        subject { file(Dir["tmp/db/migrate/*_create_activity_notification_tables.rb"].first.gsub!('tmp/', '')) }
        it { is_expected.to exist }
        if Rails::VERSION::MAJOR >= 5
          it { is_expected.to contain(/class CreateActivityNotificationTables < ActiveRecord::Migration\[\d\.\d\]/) }
        else
          it { is_expected.to contain(/class CreateActivityNotificationTables < ActiveRecord::Migration/) }
        end

        if ActivityNotification.config.orm == :active_record
          it 'can be executed to migrate scheme' do
            require subject
            CreateActivityNotificationTables.new.migrate(:down)
            CreateActivityNotificationTables.new.migrate(:up)
          end
        end
      end
    end

    context 'with CreateCustomNotifications as name argument' do
      before do
        run_generator %w(CreateCustomNotifications --tables notifications)
      end

      describe 'CreateCustomNotifications migration file' do
        subject { file(Dir["tmp/db/migrate/*_create_custom_notifications.rb"].first.gsub!('tmp/', '')) }
        it { is_expected.to exist }
        if Rails::VERSION::MAJOR >= 5
          it { is_expected.to contain(/class CreateCustomNotifications < ActiveRecord::Migration\[\d\.\d\]/) }
        else
          it { is_expected.to contain(/class CreateCustomNotifications < ActiveRecord::Migration/) }
        end

        if ActivityNotification.config.orm == :active_record
          it 'can be executed to migrate scheme' do
            require subject
            CreateActivityNotificationTables.new.migrate(:down)
            CreateActivityNotificationTables.new.migrate(:up)
          end
        end
      end
    end
  end
end