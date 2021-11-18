require 'generators/activity_notification/models_generator'

describe ActivityNotification::Generators::ModelsGenerator, type: :generator do

  # setup_default_destination
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs generating model tasks' do
    gen = generator %w(users)
    expect(gen).to receive :create_models
    expect(gen).to receive(:readme).and_return(true)
    gen.invoke_all
  end

  describe 'the generated files' do
    context 'without target argument' do
      it 'raises Thor::RequiredArgumentMissingError' do
        expect { run_generator }
        .to raise_error(Thor::RequiredArgumentMissingError)
      end
    end

    context 'with users as target' do
      context 'with target models as default' do
        before do
          run_generator %w(users)
        end

        describe 'the notification' do
          subject { file('app/models/users/notification.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::Notification < ActivityNotification::Notification/) }
        end

        describe 'the subscription' do
          subject { file('app/models/users/subscription.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::Subscription < ActivityNotification::Subscription/) }
        end
      end

      context 'with a models option as notification' do
        before do
          run_generator %w(users --models notification)
        end

        describe 'the notification' do
          subject { file('app/models/users/notification.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::Notification < ActivityNotification::Notification/) }
        end

        describe 'the subscription' do
          subject { file('app/models/users/subscription.rb') }
          it { is_expected.not_to exist }
        end
      end

      context 'with a names option as custom_notification and custom_subscription' do
        before do
          run_generator %w(users --names custom_notification custom_subscription)
        end

        describe 'the notification' do
          subject { file('app/models/users/custom_notification.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::CustomNotification < ActivityNotification::Notification/) }
        end

        describe 'the subscription' do
          subject { file('app/models/users/custom_subscription.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::CustomSubscription < ActivityNotification::Subscription/) }
        end
      end

      context 'with a models option as notification and a names option as custom_notification' do
        before do
          run_generator %w(users --models notification --names custom_notification)
        end

        describe 'the notification' do
          subject { file('app/models/users/custom_notification.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::CustomNotification < ActivityNotification::Notification/) }
        end

        describe 'the subscription' do
          subject { file('app/models/users/subscription.rb') }
          it { is_expected.not_to exist }
        end
      end
    end
  end
end