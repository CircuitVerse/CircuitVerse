shared_examples_for :notifiable do
  let(:test_class_name) { described_class.to_s.underscore.split('/').last.to_sym }
  let(:test_instance) { create(test_class_name) }
  let(:test_target) { create(:user) }

  include Rails.application.routes.url_helpers

  describe "as public class methods" do
    describe ".available_as_notifiable?" do
      it "returns true" do
        expect(described_class.available_as_notifiable?).to be_truthy
      end
    end

    describe ".set_notifiable_class_defaults" do
      it "set parameter fields as default" do
        described_class.set_notifiable_class_defaults
        expect(described_class._notification_targets).to            eq({})
        expect(described_class._notification_group).to              eq({})
        expect(described_class._notification_group_expiry_delay).to eq({})
        expect(described_class._notifier).to                        eq({})
        expect(described_class._notification_parameters).to         eq({})
        expect(described_class._notification_email_allowed).to      eq({})
        expect(described_class._notifiable_action_cable_allowed).to eq({})
        expect(described_class._notifiable_path).to                 eq({})
        expect(described_class._printable_notifiable_name).to       eq({})
      end
    end
  end

  describe "as public instance methods" do
    before do
      User.delete_all
      described_class.set_notifiable_class_defaults
      create(:user)
      create(:user)
      expect(User.all.count).to eq(2)
      expect(User.all.first).to be_an_instance_of(User)
    end

    describe "#notification_targets" do
      context "without any configuration" do
        it "raises NotImplementedError" do
          expect { test_instance.notification_targets(User, 'dummy_key') }
            .to raise_error(NotImplementedError, /You have to implement .+ or set :targets in acts_as_notifiable/)
          expect { test_instance.notification_targets(User, { key: 'dummy_key' }) }
            .to raise_error(NotImplementedError, /You have to implement .+ or set :targets in acts_as_notifiable/)
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notification_users(key)
              User.all
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notification_targets(User, 'dummy_key')).to eq(User.all)
          expect(test_instance.notification_targets(User, { key: 'dummy_key' })).to eq(User.all)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_targets[:users] = User.all
          expect(test_instance.notification_targets(User, 'dummy_key')).to eq(User.all)
          expect(test_instance.notification_targets(User, { key: 'dummy_key' })).to eq(User.all)
        end

        it "returns specified symbol without argumentss" do
          module AdditionalMethods
            def custom_notification_users
              User.all
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_targets[:users] = :custom_notification_users
          expect(test_instance.notification_targets(User, 'dummy_key')).to eq(User.all)
          expect(test_instance.notification_targets(User, { key: 'dummy_key' })).to eq(User.all)
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_notification_users(key)
              User.all
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_targets[:users] = :custom_notification_users
          expect(test_instance.notification_targets(User, 'dummy_key')).to eq(User.all)
          expect(test_instance.notification_targets(User, { key: 'dummy_key' })).to eq(User.all)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notification_targets[:users] = ->(notifiable){ User.all }
          expect(test_instance.notification_targets(User, 'dummy_key')).to eq(User.all)
          expect(test_instance.notification_targets(User, { key: 'dummy_key' })).to eq(User.all)
        end

        it "returns specified lambda with notifiable and key arguments" do
          described_class._notification_targets[:users] = ->(notifiable, key){ User.all if key == 'dummy_key' }
          expect(test_instance.notification_targets(User, 'dummy_key')).to eq(User.all)
        end

        it "returns specified lambda with notifiable and options arguments" do
          described_class._notification_targets[:users] = ->(notifiable, options){ User.all if options[:key] == 'dummy_key' }
          expect(test_instance.notification_targets(User, { key: 'dummy_key' })).to eq(User.all)
        end
      end
    end

    describe "#notification_group" do
      context "without any configuration" do
        it "returns nil" do
          expect(test_instance.notification_group(User, 'dummy_key')).to be_nil
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notification_group_for_users(key)
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notification_group(User, 'dummy_key')).to eq(User.all.first)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_group[:users] = User.all.first
          expect(test_instance.notification_group(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified symbol without argumentss" do
          module AdditionalMethods
            def custom_notification_group
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_group[:users] = :custom_notification_group
          expect(test_instance.notification_group(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_notification_group(key)
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_group[:users] = :custom_notification_group
          expect(test_instance.notification_group(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notification_group[:users] = ->(notifiable){ User.all.first }
          expect(test_instance.notification_group(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified lambda with notifiable and key arguments" do
          described_class._notification_group[:users] = ->(notifiable, key){ User.all.first }
          expect(test_instance.notification_group(User, 'dummy_key')).to eq(User.all.first)
        end
      end
    end

    describe "#notification_group_expiry_delay" do
      context "without any configuration" do
        it "returns nil" do
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to be_nil
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notification_group_expiry_delay_for_users(key)
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to eq(User.all.first)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_group_expiry_delay[:users] = User.all.first
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified symbol without argumentss" do
          module AdditionalMethods
            def custom_notification_group_expiry_delay
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_group_expiry_delay[:users] = :custom_notification_group_expiry_delay
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_notification_group_expiry_delay(key)
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_group_expiry_delay[:users] = :custom_notification_group_expiry_delay
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notification_group_expiry_delay[:users] = ->(notifiable){ User.all.first }
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified lambda with notifiable and key arguments" do
          described_class._notification_group_expiry_delay[:users] = ->(notifiable, key){ User.all.first }
          expect(test_instance.notification_group_expiry_delay(User, 'dummy_key')).to eq(User.all.first)
        end
      end
    end

    describe "#notification_parameters" do
      context "without any configuration" do
        it "returns blank hash" do
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({})
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notification_parameters_for_users(key)
              { hoge: 'fuga', foo: 'bar' }
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({ hoge: 'fuga', foo: 'bar' })
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_parameters[:users] = { hoge: 'fuga', foo: 'bar' }
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({ hoge: 'fuga', foo: 'bar' })
        end

        it "returns specified symbol without arguments" do
          module AdditionalMethods
            def custom_notification_parameters
              { hoge: 'fuga', foo: 'bar' }
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_parameters[:users] = :custom_notification_parameters
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({ hoge: 'fuga', foo: 'bar' })
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_notification_parameters(key)
              { hoge: 'fuga', foo: 'bar' }
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_parameters[:users] = :custom_notification_parameters
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({ hoge: 'fuga', foo: 'bar' })
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notification_parameters[:users] = ->(notifiable){ { hoge: 'fuga', foo: 'bar' } }
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({ hoge: 'fuga', foo: 'bar' })
        end

        it "returns specified lambda with notifiable and key arguments" do
          described_class._notification_parameters[:users] = ->(notifiable, key){ { hoge: 'fuga', foo: 'bar' } }
          expect(test_instance.notification_parameters(User, 'dummy_key')).to eq({ hoge: 'fuga', foo: 'bar' })
        end
      end
    end

    describe "#notifier" do
      context "without any configuration" do
        it "returns nil" do
          expect(test_instance.notifier(User, 'dummy_key')).to be_nil
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notifier_for_users(key)
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notifier(User, 'dummy_key')).to eq(User.all.first)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notifier[:users] = User.all.first
          expect(test_instance.notifier(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified symbol without arguments" do
          module AdditionalMethods
            def custom_notifier
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifier[:users] = :custom_notifier
          expect(test_instance.notifier(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_notifier(key)
              User.all.first
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifier[:users] = :custom_notifier
          expect(test_instance.notifier(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notifier[:users] = ->(notifiable){ User.all.first }
          expect(test_instance.notifier(User, 'dummy_key')).to eq(User.all.first)
        end

        it "returns specified lambda with notifiable and key arguments" do
          described_class._notifier[:users] = ->(notifiable, key){ User.all.first }
          expect(test_instance.notifier(User, 'dummy_key')).to eq(User.all.first)
        end
      end
    end

    describe "#notification_email_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.email_enabled" do
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key'))
            .to eq(ActivityNotification.config.email_enabled)
        end

        it "returns false as default" do
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to be_falsey
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notification_email_allowed_for_users?(target, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to eq(true)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notification_email_allowed[:users] = true
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol without arguments" do
          module AdditionalMethods
            def custom_notification_email_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_email_allowed[:users] = :custom_notification_email_allowed?
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol with target and key arguments" do
          module AdditionalMethods
            def custom_notification_email_allowed?(target, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notification_email_allowed[:users] = :custom_notification_email_allowed?
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notification_email_allowed[:users] = ->(notifiable){ true }
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with notifiable, target and key arguments" do
          described_class._notification_email_allowed[:users] = ->(notifiable, target, key){ true }
          expect(test_instance.notification_email_allowed?(test_target, 'dummy_key')).to eq(true)
        end
      end
    end

    describe "#notifiable_action_cable_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.action_cable_enabled" do
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key'))
            .to eq(ActivityNotification.config.action_cable_enabled)
        end

        it "returns false as default" do
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to be_falsey
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notifiable_action_cable_allowed_for_users?(target, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to eq(true)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notifiable_action_cable_allowed[:users] = true
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol without arguments" do
          module AdditionalMethods
            def custom_notifiable_action_cable_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifiable_action_cable_allowed[:users] = :custom_notifiable_action_cable_allowed?
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol with target and key arguments" do
          module AdditionalMethods
            def custom_notifiable_action_cable_allowed?(target, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifiable_action_cable_allowed[:users] = :custom_notifiable_action_cable_allowed?
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notifiable_action_cable_allowed[:users] = ->(notifiable){ true }
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with notifiable, target and key arguments" do
          described_class._notifiable_action_cable_allowed[:users] = ->(notifiable, target, key){ true }
          expect(test_instance.notifiable_action_cable_allowed?(test_target, 'dummy_key')).to eq(true)
        end
      end
    end

    describe "#notifiable_action_cable_api_allowed?" do
      context "without any configuration" do
        it "returns ActivityNotification.config.action_cable_api_enabled" do
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key'))
            .to eq(ActivityNotification.config.action_cable_api_enabled)
        end

        it "returns false as default" do
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to be_falsey
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notifiable_action_cable_api_allowed_for_users?(target, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to eq(true)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notifiable_action_cable_api_allowed[:users] = true
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol without arguments" do
          module AdditionalMethods
            def custom_notifiable_action_cable_api_allowed?
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifiable_action_cable_api_allowed[:users] = :custom_notifiable_action_cable_api_allowed?
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified symbol with target and key arguments" do
          module AdditionalMethods
            def custom_notifiable_action_cable_api_allowed?(target, key)
              true
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifiable_action_cable_api_allowed[:users] = :custom_notifiable_action_cable_api_allowed?
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notifiable_action_cable_api_allowed[:users] = ->(notifiable){ true }
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to eq(true)
        end

        it "returns specified lambda with notifiable, target and key arguments" do
          described_class._notifiable_action_cable_api_allowed[:users] = ->(notifiable, target, key){ true }
          expect(test_instance.notifiable_action_cable_api_allowed?(test_target, 'dummy_key')).to eq(true)
        end
      end
    end

    describe "#notifiable_path" do
      context "without any configuration" do
        it "raises NotImplementedError" do
          expect { test_instance.notifiable_path(User, 'dummy_key') }
            .to raise_error(NotImplementedError, /You have to implement .+, set :notifiable_path in acts_as_notifiable or set polymorphic_path routing for/)
        end
      end

      context "configured with polymorphic_path" do
        it "returns polymorphic_path" do
          article = create(:article)
          expect(article.notifiable_path(User, 'dummy_key')).to eq(article_path(article))
        end
      end

      context "configured with overridden method" do
        it "returns specified value" do
          module AdditionalMethods
            def notifiable_path_for_users(key)
              article_path(1)
            end
          end
          test_instance.extend(AdditionalMethods)
          expect(test_instance.notifiable_path(User, 'dummy_key')).to eq(article_path(1))
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._notifiable_path[:users] = article_path(1)
          expect(test_instance.notifiable_path(User, 'dummy_key')).to eq(article_path(1))
        end

        it "returns specified symbol without arguments" do
          module AdditionalMethods
            def custom_notifiable_path
              article_path(1)
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifiable_path[:users] = :custom_notifiable_path
          expect(test_instance.notifiable_path(User, 'dummy_key')).to eq(article_path(1))
        end

        it "returns specified symbol with key argument" do
          module AdditionalMethods
            def custom_notifiable_path(key)
              article_path(1)
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._notifiable_path[:users] = :custom_notifiable_path
          expect(test_instance.notifiable_path(User, 'dummy_key')).to eq(article_path(1))
        end

        it "returns specified lambda with single notifiable argument" do
          described_class._notifiable_path[:users] = ->(notifiable){ article_path(1) }
          expect(test_instance.notifiable_path(User, 'dummy_key')).to eq(article_path(1))
        end

        it "returns specified lambda with notifiable and key arguments" do
          described_class._notifiable_path[:users] = ->(notifiable, key){ article_path(1) }
          expect(test_instance.notifiable_path(User, 'dummy_key')).to eq(article_path(1))
        end
      end
    end

    describe "#printable_notifiable_name" do
      context "without any configuration" do
        it "returns ActivityNotification::Common.printable_name" do
          expect(test_instance.printable_notifiable_name(test_target, 'dummy_key')).to eq(test_instance.printable_name)
        end
      end

      context "configured with a field" do
        it "returns specified value" do
          described_class._printable_notifiable_name[:users] = 'test_printable_name'
          expect(test_instance.printable_notifiable_name(test_target, 'dummy_key')).to eq('test_printable_name')
        end

        it "returns specified symbol of field" do
          described_class._printable_notifiable_name[:users] = :title
          expect(test_instance.printable_notifiable_name(test_target, 'dummy_key')).to eq(test_instance.title)
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            def custom_printable_name
              'test_printable_name'
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._printable_notifiable_name[:users] = :custom_printable_name
          expect(test_instance.printable_notifiable_name(test_target, 'dummy_key')).to eq('test_printable_name')
        end

        it "returns specified lambda with notifiable, target and key argument" do
          described_class._printable_notifiable_name[:users] = ->(notifiable, target, key){ 'test_printable_name' }
          expect(test_instance.printable_notifiable_name(test_target, 'dummy_key')).to eq('test_printable_name')
        end
      end
    end

    describe "#optional_targets" do
      require 'custom_optional_targets/console_output'

      context "without any configuration" do
        it "returns blank array" do
          expect(test_instance.optional_targets(test_target, 'dummy_key')).to eq([])
        end
      end

      context "configured with a field" do
        before do
          @optional_target_instance = CustomOptionalTarget::ConsoleOutput.new
        end

        it "returns specified value" do
          described_class._optional_targets[:users] = [@optional_target_instance]
          expect(test_instance.optional_targets(User, 'dummy_key')).to eq([@optional_target_instance])
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            require 'custom_optional_targets/console_output'
            def custom_optional_targets
              [CustomOptionalTarget::ConsoleOutput.new]
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._optional_targets[:users] = :custom_optional_targets
          expect(test_instance.optional_targets(User, 'dummy_key').size).to  eq(1)
          expect(test_instance.optional_targets(User, 'dummy_key').first).to be_a(CustomOptionalTarget::ConsoleOutput)
        end

        it "returns specified lambda with no arguments" do
          described_class._optional_targets[:users] = ->{ [CustomOptionalTarget::ConsoleOutput.new] }
          expect(test_instance.optional_targets(User, 'dummy_key').first).to be_a(CustomOptionalTarget::ConsoleOutput)
        end

        it "returns specified lambda with notifiable and key argument" do
          described_class._optional_targets[:users] = ->(notifiable, key){ key == 'dummy_key' ? [CustomOptionalTarget::ConsoleOutput.new] : [] }
          expect(test_instance.optional_targets(User)).to eq([])
          expect(test_instance.optional_targets(User, 'dummy_key').first).to be_a(CustomOptionalTarget::ConsoleOutput)
        end
      end
    end

    describe "#optional_target_names" do
      require 'custom_optional_targets/console_output'

      context "without any configuration" do
        it "returns blank array" do
          expect(test_instance.optional_target_names(test_target, 'dummy_key')).to eq([])
        end
      end

      context "configured with a field" do
        before do
          @optional_target_instance = CustomOptionalTarget::ConsoleOutput.new
        end

        it "returns specified value" do
          described_class._optional_targets[:users] = [@optional_target_instance]
          expect(test_instance.optional_target_names(User, 'dummy_key')).to eq([:console_output])
        end

        it "returns specified symbol of method" do
          module AdditionalMethods
            require 'custom_optional_targets/console_output'
            def custom_optional_targets
              [CustomOptionalTarget::ConsoleOutput.new]
            end
          end
          test_instance.extend(AdditionalMethods)
          described_class._optional_targets[:users] = :custom_optional_targets
          expect(test_instance.optional_target_names(User, 'dummy_key')).to eq([:console_output])
        end

        it "returns specified lambda with no arguments" do
          described_class._optional_targets[:users] = ->{ [@optional_target_instance] }
          expect(test_instance.optional_target_names(User, 'dummy_key')).to eq([:console_output])
        end

        it "returns specified lambda with notifiable and key argument" do
          described_class._optional_targets[:users] = ->(notifiable, key){ key == 'dummy_key' ? [@optional_target_instance] : [] }
          expect(test_instance.optional_target_names(User, 'dummy_key')).to eq([:console_output])
        end
      end
    end

    describe "#notify" do
      it "is an alias of ActivityNotification::Notification.notify" do
        expect(ActivityNotification::Notification).to receive(:notify)
        test_instance.notify :users
      end
    end

    describe "#notify_later" do
      it "is an alias of ActivityNotification::Notification.notify_later" do
        expect(ActivityNotification::Notification).to receive(:notify_later)
        test_instance.notify_later :users
      end
    end

    describe "#notify_all" do
      it "is an alias of ActivityNotification::Notification.notify_all" do
        expect(ActivityNotification::Notification).to receive(:notify_all)
        test_instance.notify_all [create(:user)]
      end
    end

    describe "#notify_all_later" do
      it "is an alias of ActivityNotification::Notification.notify_all_later" do
        expect(ActivityNotification::Notification).to receive(:notify_all_later)
        test_instance.notify_all_later [create(:user)]
      end
    end

    describe "#notify_to" do
      it "is an alias of ActivityNotification::Notification.notify_to" do
        expect(ActivityNotification::Notification).to receive(:notify_to)
        test_instance.notify_to create(:user)
      end
    end

    describe "#notify_later_to" do
      it "is an alias of ActivityNotification::Notification.notify_later_to" do
        expect(ActivityNotification::Notification).to receive(:notify_later_to)
        test_instance.notify_later_to create(:user)
      end
    end

    describe "#default_notification_key" do
      it "returns '#to_resource_name.default'" do
        expect(test_instance.default_notification_key).to eq("#{test_instance.to_resource_name}.default")
      end
    end

  end

end