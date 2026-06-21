# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestsController, type: :controller do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest) }

  before do
    sign_in user
    enable_contests!
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "returns a success response for an invalid page param" do
      get :index, params: { page: "JJJ2QQQ" }
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: contest.to_param }
      expect(response).to be_successful
    end

    it "returns a success response for an invalid page param" do
      get :show, params: { id: contest.to_param, page: "JJJ2QQQ" }
      expect(response).to be_successful
    end
  end
end
