# frozen_string_literal: true

require "rails_helper"

describe CircuitverseController, type: :request do
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

  context "with invalid cursor parameters" do
    it "falls back to the initial page and returns success" do
      # Providing a deliberately invalid 'after' parameter that can't be base64 decoded
      get root_path(after: "invalid_base64_cursor$$$")

      # The controller should rescue the error and still return a 200 status
      expect(response.status).to eq(200)
    end
  end
end
