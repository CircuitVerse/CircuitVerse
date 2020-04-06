# frozen_string_literal: true

require "rails_helper"

describe ErrorsController, type: :request do
  describe "#not_found" do
    it "should return 404" do
      get "/404"
      expect(response.body).to include("OOPS,THE PAGE YOU ARE LOOKING FOR CAN'T BE FOUND!")
      expect(response.body).to include("404")
    end
  end

  describe "#not_found" do
    it "should return 404" do
      get "/500"
      expect(response.body).to include("SERVER ERRORED!, IT'S ME NOT YOU, LET'S TRY AGAIN :)")
      expect(response.body).to include("500")
    end
  end

  describe "#not_found" do
    it "should return 404" do
      get "/422"
      expect(response.body).to include("UNPROCESSABLE ENTITY!, REQUEST COULD NOT BE PROCESSED :(")
      expect(response.body).to include("422")
    end
  end
end
