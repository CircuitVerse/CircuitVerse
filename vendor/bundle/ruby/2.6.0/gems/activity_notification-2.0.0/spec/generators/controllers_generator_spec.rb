require 'generators/activity_notification/controllers_generator'

describe ActivityNotification::Generators::ControllersGenerator, type: :generator do

  # setup_default_destination
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs generating controllers tasks' do
    gen = generator %w(users)
    expect(gen).to receive :create_controllers
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
      context 'with target controllers as default' do
        before do
          run_generator %w(users)
        end

        describe 'the notifications_controller' do
          subject { file('app/controllers/users/notifications_controller.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::NotificationsController < ActivityNotification::NotificationsController/) }
        end

        describe 'the notifications_with_devise_controller' do
          subject { file('app/controllers/users/notifications_with_devise_controller.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::NotificationsWithDeviseController < ActivityNotification::NotificationsWithDeviseController/) }
        end

        describe 'the subscriptions_controller' do
          subject { file('app/controllers/users/subscriptions_controller.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::SubscriptionsController < ActivityNotification::SubscriptionsController/) }
        end

        describe 'the subscriptions_with_devise_controller' do
          subject { file('app/controllers/users/subscriptions_with_devise_controller.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::SubscriptionsWithDeviseController < ActivityNotification::SubscriptionsWithDeviseController/) }
        end
      end

      context 'with a controllers option as notifications and subscriptions' do
        before do
          run_generator %w(users --controllers notifications subscriptions)
        end

        describe 'the notifications_controller' do
          subject { file('app/controllers/users/notifications_controller.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::NotificationsController < ActivityNotification::NotificationsController/) }
        end

        describe 'the notifications_with_devise_controller' do
          subject { file('app/controllers/users/notifications_with_devise_controller.rb') }
          it { is_expected.not_to exist }
        end

        describe 'the subscriptions_controller' do
          subject { file('app/controllers/users/subscriptions_controller.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/class Users::SubscriptionsController < ActivityNotification::SubscriptionsController/) }
        end

        describe 'the subscriptions_with_devise_controller' do
          subject { file('app/controllers/users/subscriptions_with_devise_controller.rb') }
          it { is_expected.not_to exist }
        end
      end
    end

  end
end