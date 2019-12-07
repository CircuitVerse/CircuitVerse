# frozen_string_literal: true

require "rails_helper"

describe Users::NotificationsController, type: :request do
  it "should get index page" do
    get root_path
    expect(response.status).to eq(200)
  end
end
