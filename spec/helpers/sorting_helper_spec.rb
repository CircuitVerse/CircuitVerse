# frozen_string_literal: true

require "rails_helper"

RSpec.describe SortingHelper, type: :helper do
  describe SortingHelper do
    it "#sort_fields" do
      sort = "-field1,field2,field3"
      allowed = %i[field1 field2]
      sort_fields = described_class.sort_fields(sort, allowed)
      expect(sort_fields.key?("field3")).to be false
    end

    it "returns ordered hash" do
      fields = ["-field1", "field2"]
      ordered_hash = described_class.ordered_hash(fields)
      expect(ordered_hash).to include("field1" => :desc, "field2" => :asc)
    end
  end
end
