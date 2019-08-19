# frozen_string_literal: true

require "rails_helper"

describe SearchHelper do
  include SearchHelper

  let(:query_params) {
    {
      resource: @resource,
      q: "dummy query"
    }
  }

  describe "#query" do
    context "resource is Users" do
      it "should return correct template" do
        @resource = "Users"
        _, template = query(@resource, query_params)

        expect(template).to eq("/users/logix/search")
      end
    end

    context "resource if Projects" do
      it "should return correct template" do
        @resource = "Projects"
        _, template = query(@resource, query_params)

        expect(template).to eq("/projects/search")
      end
    end
  end
end
