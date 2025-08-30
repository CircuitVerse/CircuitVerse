# frozen_string_literal: true

require "rails_helper"

describe ErrorsController, type: :request do
  before do
    @original_show_exceptions = Rails.application.config.action_dispatch.show_exceptions
    @original_consider_all_requests_local = Rails.application.config.consider_all_requests_local
    Rails.application.config.action_dispatch.show_exceptions = :all
    Rails.application.config.consider_all_requests_local = false
  end

  after do
    Rails.application.config.action_dispatch.show_exceptions = @original_show_exceptions
    Rails.application.config.consider_all_requests_local = @original_consider_all_requests_local
  end

  describe "#not_found" do
    it "returns 404" do
      get "/404"
      expect(response.body).to include("Sorry, an error has occured, Requested page not found!")
      expect(response.body).to include("404 Not Found")
    end
  end

  describe "#internal_error" do
    it "returns 500" do
      get "/500"
      expect(response.body).to include("Sorry, an error has occured, Internal Server Error!")
      expect(response.body).to include("500 Internal Server Error")
    end
  end

  describe "#unacceptable" do
    it "returns 422" do
      get "/422"
      expect(response.body).to include("Sorry, an error has occured, Unprocessable Entity!")
      expect(response.body).to include("422 Unprocessable Entity")
    end
  end
end
