# frozen_string_literal: true

require "rails_helper"

describe AboutController do
  it "gets about page" do
    get about_index_path
     expect(response).to have_http_status(200)
  end
end
