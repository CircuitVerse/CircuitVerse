# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::DeepLinkingSettings do
  include ActiveSupport::Testing::TimeHelpers

  let(:settings) do
    { "deep_link_return_url" => "https://canvas.example.com/courses/1/deep_link",
      "accept_types" => %w[ltiResourceLink],
      "accept_presentation_document_targets" => %w[iframe window],
      "accept_multiple" => true,
      "data" => "opaque-platform-state" }
  end

  def payload(overrides = {})
    { described_class::MESSAGE_TYPE_CLAIM => described_class::MESSAGE_TYPE,
      described_class::SETTINGS_CLAIM => settings }.merge(overrides)
  end

  describe ".requested?" do
    it "recognises a deep linking request" do
      expect(described_class).to be_requested(payload)
    end

    it "ignores a resource link launch" do
      expect(described_class).not_to be_requested(
        payload(described_class::MESSAGE_TYPE_CLAIM => "LtiResourceLinkRequest")
      )
    end
  end

  describe ".from_claim" do
    subject(:parsed) { described_class.from_claim(payload) }

    it "reads where the picker must return to" do
      expect(parsed.return_url).to eq("https://canvas.example.com/courses/1/deep_link")
    end

    it "reads what the platform will accept" do
      expect(parsed).to have_attributes(accept_types: %w[ltiResourceLink],
                                        document_targets: %w[iframe window],
                                        accept_multiple?: true)
    end

    it "keeps the platform's opaque data" do
      expect(parsed.data).to eq("opaque-platform-state")
    end

    it "refuses a request with nowhere to return to" do
      settings.delete("deep_link_return_url")
      expect { parsed }.to raise_error(described_class::Error, /return_url/)
    end

    it "refuses a request with no settings at all" do
      expect { described_class.from_claim({}) }.to raise_error(described_class::Error)
    end

    it "refuses a settings claim that is not an object" do
      expect { described_class.from_claim(described_class::SETTINGS_CLAIM => "nonsense") }
        .to raise_error(described_class::Error, /malformed/)
    end

    it "refuses a return url that is not absolute" do
      settings["deep_link_return_url"] = "/courses/1/deep_link"
      expect { parsed }.to raise_error(described_class::Error, /return_url/)
    end

    it "refuses a return url with a scheme we would never post to" do
      settings["deep_link_return_url"] = "javascript:alert(1)"
      expect { parsed }.to raise_error(described_class::Error, /return_url/)
    end

    it "refuses a malformed return url" do
      settings["deep_link_return_url"] = "https://exa mple.com/%%"
      expect { parsed }.to raise_error(described_class::Error, /return_url/)
    end

    it "refuses a plain http return url in production" do
      settings["deep_link_return_url"] = "http://canvas.example.com/deep_link"
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

      expect { parsed }.to raise_error(described_class::Error, /return_url/)
    end

    it "allows a plain http return url outside production" do
      settings["deep_link_return_url"] = "http://canvas.docker/deep_link"
      expect(parsed.return_url).to eq("http://canvas.docker/deep_link")
    end
  end

  describe "stashing" do
    it "restores everything the response will need" do
      restored = described_class.restore(described_class.from_claim(payload).stash)

      expect(restored).to have_attributes(
        return_url: "https://canvas.example.com/courses/1/deep_link",
        accept_types: %w[ltiResourceLink], document_targets: %w[iframe window],
        accept_multiple?: true, data: "opaque-platform-state"
      )
    end

    it "refuses a tampered stash" do
      stashed = described_class.from_claim(payload).stash
      expect { described_class.restore("#{stashed}x") }.to raise_error(described_class::Error)
    end

    it "refuses a stash signed for another purpose" do
      forged = Rails.application.message_verifier("other.purpose")
                    .generate(settings, purpose: "other.purpose")
      expect { described_class.restore(forged) }.to raise_error(described_class::Error)
    end

    it "refuses a stash the instructor left too long" do
      stashed = described_class.from_claim(payload).stash

      travel_to(31.minutes.from_now) do
        expect { described_class.restore(stashed) }.to raise_error(described_class::Error)
      end
    end

    it "refuses a missing stash" do
      expect { described_class.restore(nil) }.to raise_error(described_class::Error)
    end
  end
end
