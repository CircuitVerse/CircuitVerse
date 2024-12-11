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
    it "falls back to the initial page with an invalid after parameter" do
      get root_path(after: "invalid_base64_cursor$$$")
      expect(response.status).to eq(200)
    end

    it "falls back to the initial page with an invalid before parameter" do
      get root_path(before: "invalid_base64_cursor$$$")
      expect(response.status).to eq(200)
    end
  end
end
