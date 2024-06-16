# frozen_string_literal: true

require "rails_helper"

RSpec.describe "QuestionSubmissions", type: :request do
  describe "GET /post_submission" do
    it "returns http success" do
      get "/question_submission/post_submission"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show_submission" do
    it "returns http success" do
      get "/question_submission/show_submission"
      expect(response).to have_http_status(:success)
    end
  end
end
