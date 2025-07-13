# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestsController, type: :controller do
  let(:user) { create(:user) }
  let(:contest) { create(:contest) }

  before do
    sign_in user
    flipper_enable(:contests)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: contest.to_param }
      expect(response).to be_successful
    end
  end
end
