# frozen_string_literal: true

require "rails_helper"

RSpec.describe SafeAutoLinkHelper, type: :helper do
  describe "#safe_auto_link" do
    context "with normal text containing URLs" do
      it "converts URLs to links" do
        text = "Check out https://circuitverse.org for more info"
        result = helper.safe_auto_link(text)

        expect(result).to include('href="https://circuitverse.org"')
        expect(result).to include("Check out")
      end

      it "converts multiple URLs to links" do
        text = "Visit https://example.com and https://test.com"
        result = helper.safe_auto_link(text)

        expect(result).to include('href="https://example.com"')
        expect(result).to include('href="https://test.com"')
      end

      it "forwards options to auto_link" do
        text = "Visit https://example.com"
        result = helper.safe_auto_link(text, html: { target: "_blank", rel: "noopener" })

        expect(result).to include('target="_blank"')
        expect(result).to include('rel="noopener"')
      end
    end

    context "with plain text without URLs" do
      it "returns the text as-is" do
        text = "This is plain text without any URLs"
        result = helper.safe_auto_link(text)

        expect(result).to eq(text)
      end
    end

    context "with blank or nil input" do
      it "returns empty string for nil" do
        expect(helper.safe_auto_link(nil)).to eq("")
      end

      it "returns empty string for empty string" do
        expect(helper.safe_auto_link("")).to eq("")
      end

      it "returns empty string for whitespace only" do
        expect(helper.safe_auto_link("   ")).to eq("")
      end
    end

    context "with very long text" do
      it "truncates text exceeding MAX_AUTO_LINK_LENGTH" do
        long_text = "a" * 15_000
        result = helper.safe_auto_link(long_text)

        expect(result.length).to eq(SafeAutoLinkHelper::MAX_AUTO_LINK_LENGTH)
        expect(result).to include("[content truncated]")
      end

      it "processes text exactly at MAX_AUTO_LINK_LENGTH without truncation" do
        exact_length_text = "a" * SafeAutoLinkHelper::MAX_AUTO_LINK_LENGTH
        result = helper.safe_auto_link(exact_length_text)

        expect(result).not_to include("[content truncated]")
        expect(result.length).to eq(SafeAutoLinkHelper::MAX_AUTO_LINK_LENGTH)
      end
    end

    context "when timeout occurs" do
      before do
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
      end

      it "returns sanitized text on timeout" do
        text = "<script>alert('xss')</script> with https://example.com"
        result = helper.safe_auto_link(text)

        # Should return escaped text, not raise error
        expect(result).to be_present
        expect(result).not_to include("<script>")
        expect(result).to include("&lt;script&gt;")
      end

      it "logs a warning on timeout" do
        allow(Rails.logger).to receive(:warn)

        helper.safe_auto_link("test text")

        expect(Rails.logger).to have_received(:warn).with(/Timeout while processing auto_link/)
      end
    end

    context "when Regexp::TimeoutError occurs" do
      # Regexp::TimeoutError is raised directly by regex operations inside
      # auto_link, not by Timeout.timeout itself. We mock it via
      # Timeout.timeout here only as a convenient injection point.
      before do
        allow(Timeout).to receive(:timeout).and_raise(Regexp::TimeoutError)
      end

      it "returns sanitized text on regexp timeout" do
        text = "Some text"
        result = helper.safe_auto_link(text)

        expect(result).to be_present
      end
    end

    context "with potentially malicious input" do
      it "escapes HTML in fallback" do
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)

        text = "<script>alert('xss')</script>"
        result = helper.safe_auto_link(text)

        expect(result).not_to include("<script>")
        expect(result).to include("&lt;script&gt;")
      end
    end
  end
end
