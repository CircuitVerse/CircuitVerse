require 'rails_helper'

RSpec.describe Subgroup, type: :model do
 it "is valid with a name and group" do
    group = Group.create!(name: "Test Group")
    subgroup = Subgroup.new(name: "Subgroup A", group: group)

    expect(subgroup).to be_valid
  end

  it "is invalid without a name" do
    group = Group.create!(name: "Test Group")
    subgroup = Subgroup.new(name: nil, group: group)

    expect(subgroup).not_to be_valid
  end

  it "is invalid without a group" do
    subgroup = Subgroup.new(name: "Subgroup A", group: nil)

    expect(subgroup).not_to be_valid
  end
end
