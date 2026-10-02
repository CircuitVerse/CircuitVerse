# frozen_string_literal: true

require "rails_helper"

# Covers config/initializers/omniauth_github.rb: GitHub's /user and /user/emails
# endpoints are fetched concurrently (issue #7875) while #email still resolves to
# the same primary verified address as the stock sequential flow, so account
# matching in User.from_omniauth is unchanged.
RSpec.describe OmniAuth::Strategies::GitHub do
  let(:strategy) { described_class.new(->(_env) { [200, {}, []] }) }

  # Thread-safe record of the paths hit by the (parallel) fetch.
  let(:requested_paths) { Queue.new }

  let(:access_token) do
    paths = requested_paths
    token_options = {}
    responses = {
      "user" => { "id" => 1, "login" => "octocat", "name" => "The Octocat", "email" => nil },
      "user/emails" => [
        { "email" => "secondary@example.com", "primary" => false, "verified" => true },
        { "email" => "octocat@example.com", "primary" => true, "verified" => true }
      ]
    }

    Object.new.tap do |token|
      token.define_singleton_method(:options) { token_options }
      token.define_singleton_method(:get) do |path, *_args|
        paths << path
        parsed = responses.fetch(path)
        Object.new.tap { |response| response.define_singleton_method(:parsed) { parsed } }
      end
    end
  end

  # Stub the strategy's two inputs: the OAuth token (an external collaborator) and
  # the user:email scope gate (configured in config/initializers/devise.rb), so the
  # example exercises the parallel fetch rather than OmniAuth's option parsing.
  before do
    allow(strategy).to receive_messages(access_token: access_token, email_access_allowed?: true)
  end

  it "returns the parsed GitHub profile" do
    expect(strategy.raw_info).to include("login" => "octocat", "name" => "The Octocat")
  end

  it "resolves the same primary verified email as the sequential flow" do
    expect(strategy.email).to eq("octocat@example.com")
  end

  it "requests both the profile and the email list concurrently" do
    user_started = Queue.new
    emails_started = Queue.new

    allow(access_token).to receive(:get) do |path, *_args|
      requested_paths << path
      case path
      when "user"
        user_started << true
        raise "Sequential execution: user/emails did not start concurrently" unless emails_started.pop(timeout: 2)

        Object.new.tap do |res|
          res.define_singleton_method(:parsed) { { "id" => 1, "login" => "octocat" } }
        end
      when "user/emails"
        emails_started << true
        raise "Sequential execution: user did not start concurrently" unless user_started.pop(timeout: 2)

        Object.new.tap do |res|
          res.define_singleton_method(:parsed) { [{ "email" => "octocat@example.com", "primary" => true }] }
        end
      end
    end

    strategy.raw_info
    strategy.emails

    collected = []
    collected << requested_paths.pop until requested_paths.empty?
    expect(collected).to contain_exactly("user", "user/emails")
  end

  it "cancels the email worker if the profile request fails" do
    email_worker_thread = nil
    email_started = Queue.new

    allow(access_token).to receive(:get) do |path, *_args|
      case path
      when "user"
        email_started.pop(timeout: 2)
        raise StandardError, "Failed to fetch user profile"
      when "user/emails"
        email_worker_thread = Thread.current
        email_started << true
        sleep 5
      end
    end

    expect { strategy.raw_info }.to raise_error(StandardError, "Failed to fetch user profile")
    email_worker_thread.join(1)
    expect(email_worker_thread).not_to be_alive
  end

  context "when email access is disallowed" do
    before do
      allow(strategy).to receive(:email_access_allowed?).and_return(false)
    end

    it "returns an empty array for emails and only fetches user" do
      expect(strategy.emails).to eq([])

      strategy.raw_info

      collected = []
      collected << requested_paths.pop until requested_paths.empty?
      expect(collected).to contain_exactly("user")
    end
  end
end
