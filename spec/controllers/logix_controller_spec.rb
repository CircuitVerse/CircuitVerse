# frozen_string_literal: true

require "rails_helper"

describe LogixController, type: :request do
  it "should get index page" do
    get root_path
    expect(response.status).to eq(200)
  end

  it "should get gettingStarted" do
    get gettingStarted_path
    expect(response.status).to eq(200)
  end

  it "should get examples page" do
    get examples_path
    expect(response.status).to eq(200)
  end

  it "should get features page" do
    get features_path
    expect(response.status).to eq(200)
  end

  it "should get tos page" do
    get tos_path
    expect(response.status).to eq(200)
  end

  it "should get teachers page" do
    get teachers_path
    expect(response.status).to eq(200)
  end

  it "should get contribute page" do
    get contribute_path
    expect(response.status).to eq(200)
  end
end
