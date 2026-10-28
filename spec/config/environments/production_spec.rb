# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Production Mailer Configuration", type: :mailer do
  let(:subsystems) do
    %i[
      action_mailer action_controller active_storage active_job
      active_record active_support public_file_server i18n
    ]
  end

  let(:isolated_config) do
    config = ActiveSupport::OrderedOptions.new
    subsystems.each do |subsystem|
      config[subsystem] = ActiveSupport::OrderedOptions.new
    end
    config
  end

  let(:context) do
    Struct.new(:config) do
      def routes
        Rails.application.routes
      end
    end.new(isolated_config)
  end

  before do
    allow(Rails.application).to receive(:configure) do |&block|
      context.instance_eval(&block)
    end
  end

  it "configures ses_v2 delivery method with persistent client and timeout settings", :aggregate_failures do
    original_key = ENV.fetch("AWS_ACCESS_KEY_ID_SES", nil)
    original_secret = ENV.fetch("AWS_SECRET_ACCESS_KEY_SES", nil)
    original_region = ENV.fetch("AWS_REGION", nil)

    begin
      ENV["AWS_ACCESS_KEY_ID_SES"] = "test_key"
      ENV["AWS_SECRET_ACCESS_KEY_SES"] = "test_secret"
      ENV["AWS_REGION"] = "us-east-1"

      load Rails.root.join("config/environments/production.rb")
    ensure
      ENV["AWS_ACCESS_KEY_ID_SES"] = original_key
      ENV["AWS_SECRET_ACCESS_KEY_SES"] = original_secret
      ENV["AWS_REGION"] = original_region
    end

    expect(isolated_config.action_mailer.delivery_method).to eq(:ses_v2)

    ses_settings = isolated_config.action_mailer.ses_v2_settings
    expect(ses_settings).to be_a(Hash)
    expect(ses_settings).to have_key(:sesv2_client)

    client = ses_settings[:sesv2_client]
    expect(client).to be_an_instance_of(Aws::SESV2::Client)
    expect(client.config.http_open_timeout).to eq(5)
    expect(client.config.http_read_timeout).to eq(15)
    expect(client.config.retry_mode).to eq("standard")
    expect(client.config.max_attempts).to eq(3)
  end
end
