require 'generators/activity_notification/install_generator'

describe ActivityNotification::Generators::InstallGenerator, type: :generator do

  # setup_default_destination
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs both the initializer and locale tasks' do
    gen = generator
    expect(gen).to receive :copy_initializer
    expect(gen).to receive :copy_locale
    expect(gen).to receive(:readme).and_return(true)
    gen.invoke_all
  end

  describe 'the generated files' do
    context 'with active_record orm as default' do
      before do
        run_generator
      end

      describe 'the initializer' do
        subject { file('config/initializers/activity_notification.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/ActivityNotification.configure do |config|/) }
      end

      describe 'the locale file' do
        subject { file('config/locales/activity_notification.en.yml') }
        it { is_expected.to exist }
        it { is_expected.to contain(/en:\n.+notification:\n.+default:/) }
      end
    end

    context 'with orm option as not :active_record' do
      it 'raises MissingORMError' do
        expect { run_generator %w(--orm dummy) }
        .to raise_error(TypeError)
      end
    end
  end
end