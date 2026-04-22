require 'rails_helper'

RSpec.describe Organization, type: :model do
  it "is valid with valid attributes" do
    org = Organization.new(name: "Test Org", slug: "test-org")
    expect(org).to be_valid
  end

  it "is invalid without name" do
    org = Organization.new(slug: "test-org")
    expect(org).not_to be_valid
  end

  it "is invalid without slug" do
    org = Organization.new(name: "Test Org")
    expect(org).not_to be_valid
  end

  it "has many groups" do
    assoc = Organization.reflect_on_association(:groups)
    expect(assoc.macro).to eq(:has_many)
  end
end
