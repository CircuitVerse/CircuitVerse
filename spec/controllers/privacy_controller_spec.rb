# frozen_string_literal: true

require "rails_helper"

describe PrivacyController do
  it "gets privacy page" do
    get privacy_index_path
    expect(response).to have_http_status(200)
  end
end
