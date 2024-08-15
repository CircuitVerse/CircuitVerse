# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrimaryButtonComponent, type: :component do
  let(:label) { "Test Button" }
  let(:url) { "/test-url" }
  let(:css_classes) { "test-class" }

  subject { render_inline(described_class.new(label: label, url: url, css_classes: css_classes)) }

  # Test for correct label rendering
  it "renders a link with the correct label" do
    expect(subject.css("a").text).to eq(label)
  end

  # Test for correct URL rendering
  it "renders a link with the correct URL" do
    expect(subject.css("a").attribute("href").value).to eq(url)
  end

  # Test for applying correct CSS classes
  it "applies the correct CSS classes" do
    expect(subject.css("a").attribute("class").value).to include("btn primary-button")
    expect(subject.css("a").attribute("class").value).to include(css_classes)
  end

  context "with different inputs" do
    let(:label) { "Another Test Button" }
    let(:url) { "/another-url" }
    let(:css_classes) { "another-class" }

    # Test with different label, URL, and CSS classes
    it "renders correctly with different label, URL, and CSS classes" do
      expect(subject.css("a").text).to eq(label)
      expect(subject.css("a").attribute("href").value).to eq(url)
      expect(subject.css("a").attribute("class").value).to include("btn primary-button another-class")
    end
  end

  context "when a block is provided" do
    # Test for rendering content from a block
    subject { render_inline(described_class.new(url: url, css_classes: css_classes)) { "Block Content" } }

    it "renders the block content within the link" do
      expect(subject.css("a").text).to eq("Block Content")
    end
  end

  context "without optional parameters" do
    # Test default URL handling when no URL is provided
    subject { render_inline(described_class.new(label: label)) }

    it "renders with default URL" do
      expect(subject.css("a").attribute("href").value).to eq("#")  # Ensure default URL is set correctly
    end

    # Test default CSS classes when no CSS classes are provided
    it "applies the default CSS classes" do
      expect(subject.css("a").attribute("class").value).to include("btn primary-button")  # Ensure default CSS classes are applied
    end
  end
end
