# frozen_string_literal: true

require "rails_helper"

describe CircuitverseController, type: :request do
  # Tests for public routes
  it "gets index page" do
    get root_path
    expect(response.status).to eq(200)
  end

  it "gets examples page" do
    get examples_path
    expect(response.status).to eq(200)
  end

  it "gets tos page" do
    get tos_path
    expect(response.status).to eq(200)
  end

  it "gets teachers page" do
    get teachers_path
    expect(response.status).to eq(200)
  end

  it "gets contribute page" do
    get contribute_path
    expect(response.status).to eq(200)
  end

  # Tests for valid_cursor? method
  describe "#valid_cursor?" do
    controller = described_class.new

    it "returns true for valid cursors" do
      expect(controller.send(:valid_cursor?, "abc123-XYZ_")).to be(true)
      expect(controller.send(:valid_cursor?, "MTIzNDU2Nzg5MA==")).to be(true)
    end

    it "returns false for cursors exceeding 64 characters" do
      long_cursor = "a" * 65
      expect(controller.send(:valid_cursor?, long_cursor)).to be(false)
    end

    it "returns false for cursors with invalid characters" do
      expect(controller.send(:valid_cursor?, "invalid@cursor!")).to be(false)
    end

    it "returns false for blank or nil cursors" do
      expect(controller.send(:valid_cursor?, nil)).to be(false)
      expect(controller.send(:valid_cursor?, "")).to be(false)
    end
  end
end
