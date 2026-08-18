# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::RosterImport do
  let(:deployment) { FactoryBot.create(:lti_deployment) }
  let(:group)      { FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user)) }

  def member(id, overrides = {})
    { "user_id" => id, "status" => "Active", "name" => "Student #{id}",
      "email" => "#{id}@example.com" }.merge(overrides)
  end

  def import(members)
    described_class.call(group, members, deployment)
  end

  describe ".call" do
    it "provisions a user keyed on the deployment and platform subject" do
      import([member("sub-1")])

      expect(User.last).to have_attributes(provider: "lti", uid: "#{deployment.id}:sub-1",
                                           email: "sub-1@example.com")
    end

    it "adds them to the group and marks the membership as synced" do
      import([member("sub-1")])

      expect(GroupMember.last).to have_attributes(group: group, lti_synced: true)
    end

    it "returns the users it added" do
      expect(import([member("sub-1"), member("sub-2")]).size).to eq(2)
    end

    it "reuses a user who has launched before rather than duplicating them" do
      existing = FactoryBot.create(:user, provider: "lti", uid: "#{deployment.id}:sub-1")
      group

      expect { import([member("sub-1")]) }.not_to change(User, :count)
      expect(GroupMember.last.user).to eq(existing)
    end

    it "is safe to run twice" do
      import([member("sub-1")])

      expect { import([member("sub-1")]) }.not_to change(GroupMember, :count)
    end

    it "leaves a member added by hand unmarked, so a later sync cannot remove them" do
      user = FactoryBot.create(:user, provider: "lti", uid: "#{deployment.id}:sub-1")
      GroupMember.create!(group: group, user: user)

      import([member("sub-1")])

      expect(GroupMember.find_by(group: group, user: user).lti_synced).to be(false)
    end

    it "keeps the same subject separate across deployments" do
      other = FactoryBot.create(:lti_deployment)
      import([member("sub-1")])
      described_class.call(group, [member("sub-1", "email" => "elsewhere@example.com")], other)

      expect(User.where(provider: "lti").pluck(:uid))
        .to contain_exactly("#{deployment.id}:sub-1", "#{other.id}:sub-1")
    end

    it "skips members the platform reports as inactive" do
      expect(import([member("sub-1", "status" => "Inactive")])).to be_empty
    end

    it "skips members the platform will not name" do
      expect(import([member("sub-1", "email" => nil)])).to be_empty
    end

    it "does not demote the group's mentor into a member" do
      mentor = FactoryBot.create(:user, provider: "lti", uid: "#{deployment.id}:sub-1")
      mentored = FactoryBot.create(:group, primary_mentor: mentor)

      expect { described_class.call(mentored, [member("sub-1")], deployment) }
        .not_to change(GroupMember, :count)
    end

    it "keeps importing when one member cannot be provisioned" do
      FactoryBot.create(:user, email: "sub-1@example.com")

      expect(import([member("sub-1"), member("sub-2")]).size).to eq(1)
    end
  end
end
