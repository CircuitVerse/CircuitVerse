# frozen_string_literal: true

require "rails_helper"

describe SearchHelper do
  include described_class

  let(:query_params) do
    {
      resource: @resource,
      q: "dummy query"
    }
  end

  describe "#query" do
    context "resource is Users" do
      it "returns correct template" do
        @resource = "Users"
        _, template = query(@resource, query_params)

        expect(template).to eq("/users/circuitverse/search")
      end
    end

    context "resource if Projects" do
      it "returns correct template" do
        @resource = "Projects"
        _, template = query(@resource, query_params)

        expect(template).to eq("/projects/search")
      end
    end
  end
end
