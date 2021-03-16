# frozen_string_literal: true

require "rails_helper"

describe AboutController, type: :request do
  it "gets about page" do
    get about_index_path
    expect(response.status).to eq(200)
  end
end
