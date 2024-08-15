# frozen_string_literal: true

require 'simplecov'
require 'webmock'
require 'vcr'

require 'pry'

class InceptionFormatter
  def format(result)
    Coveralls::SimpleCov::Formatter.new.format(result)
  end
end

def setup_formatter
  if ENV['GITHUB_ACTIONS']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end
  end

  SimpleCov.formatter =
    if ENV['CI'] || ENV['COVERALLS_REPO_TOKEN']
      if ENV['GITHUB_ACTIONS']
        SimpleCov::Formatter::MultiFormatter.new([InceptionFormatter, SimpleCov::Formatter::LcovFormatter])
      else
        InceptionFormatter
      end
    else
      SimpleCov::Formatter::HTMLFormatter
    end

  SimpleCov.start do
    add_filter do |source_file|
      source_file.filename.include?('spec') && !source_file.filename.include?('fixture')
    end
    add_filter %r{/.bundle/}
  end
end

setup_formatter

require 'coveralls'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include WebMock::API

  config.after(:suite) do
    setup_formatter
    WebMock.disable!
  end
end

def stub_api_post
  body = '{"message":"","url":""}'
  stub_request(:post, "#{Coveralls::API::API_BASE}/jobs")
    .to_return(status: 200, body: body, headers: {})
end

def silence(&block)
  return yield if ENV['silence'] == 'false'

  silence_stream($stdout, &block)
end

def silence_stream(stream)
  old_stream = stream.dup
  stream.reopen(IO::NULL)
  stream.sync = true
  yield
ensure
  stream.reopen(old_stream)
  old_stream.close
end
