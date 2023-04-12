require 'rails'
require 'flipper/railtie'

RSpec.describe Flipper::Railtie do
  let(:application) do
    Class.new(Rails::Application).create(railties: [Flipper::Railtie]) do
      config.eager_load = false
    end
  end

  before do
    ActiveSupport::Dependencies.autoload_paths = ActiveSupport::Dependencies.autoload_paths.dup
    ActiveSupport::Dependencies.autoload_once_paths = ActiveSupport::Dependencies.autoload_once_paths.dup
  end

  let(:config) { application.config.flipper }

  subject { application.initialize! }

  describe 'initializers' do
    it 'can set env_key from ENV' do
      ENV['FLIPPER_ENV_KEY'] = 'flopper'

      subject
      expect(config.env_key).to eq('flopper')
    end

    it 'can set memoize from ENV' do
      ENV['FLIPPER_MEMOIZE'] = 'false'

      subject
      expect(config.memoize).to eq(false)
    end

    it 'can set preload from ENV' do
      ENV['FLIPPER_PRELOAD'] = 'false'

      subject
      expect(config.preload).to eq(false)
    end

    it 'can set instrumenter from ENV' do
      stub_const('My::Cool::Instrumenter', Class.new)
      ENV['FLIPPER_INSTRUMENTER'] = 'My::Cool::Instrumenter'

      subject
      expect(config.instrumenter).to eq(My::Cool::Instrumenter)
    end

    it 'can set log from ENV' do
      ENV['FLIPPER_LOG'] = 'false'

      subject
      expect(config.log).to eq(false)
    end

    it 'sets defaults' do
      subject # initialize
      expect(config.env_key).to eq("flipper")
      expect(config.memoize).to be(true)
      expect(config.preload).to be(true)
    end

    it "configures instrumentor on default instance" do
      subject # initialize
      expect(Flipper.instance.instrumenter).to eq(ActiveSupport::Notifications)
    end

    it 'uses Memoizer middleware if config.memoize = true' do
      initializer { config.memoize = true }
      expect(subject.middleware).to include(Flipper::Middleware::Memoizer)
    end

    it 'does not use Memoizer middleware if config.memoize = false' do
      initializer { config.memoize = false }
      expect(subject.middleware).not_to include(Flipper::Middleware::Memoizer)
    end

    it 'passes config to memoizer' do
      initializer do
        config.update(
          env_key: 'my_flipper',
          preload: [:stats, :search]
        )
      end

      expect(subject.middleware).to include(Flipper::Middleware::Memoizer)
      middleware = subject.middleware.detect { |m| m.klass == Flipper::Middleware::Memoizer }
      expect(middleware.args[0]).to eq({
        env_key: config.env_key,
        preload: config.preload,
        if: nil
      })
    end

    it "defines #flipper_id on AR::Base" do
      subject
      require 'active_record'
      expect(ActiveRecord::Base.ancestors).to include(Flipper::Identifier)
    end
  end

  # Add app initializer in the same order as config/initializers/*
  def initializer(&block)
    application.initializer 'spec', before: :load_config_initializers do
      block.call
    end
  end
end
