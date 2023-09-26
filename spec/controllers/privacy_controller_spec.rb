# frozen_string_literal: true

require "rails_helper"

describe PrivacyController, type: :request do
  it "gets privacy page" do
    get privacy_index_path
    expect(response).have_http_status(200)
  end
end
