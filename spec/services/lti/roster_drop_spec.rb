# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::RosterDrop do
  let(:deployment) { FactoryBot.create(:lti_deployment) }
  let(:group)      { FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user)) }

  def member(id, status: "Active")
    { "user_id" => id, "status" => status }
  end

  def synced_member(sub, deployment_id: deployment.id, synced: true)
    user = FactoryBot.create(:user, provider: "lti", uid: "#{deployment_id}:#{sub}")
    GroupMember.create!(group: group, user: user, lti_synced: synced)
    user
  end

  def drop(members)
    described_class.call(group, members, deployment)
  end

  describe ".call" do
    it "removes a member the roster no longer lists" do
      synced_member("sub-1")

      expect { drop([]) }.to change(GroupMember, :count).by(-1)
    end

    it "removes a member the platform now reports as inactive" do
      synced_member("sub-1")

      expect { drop([member("sub-1", status: "Inactive")]) }.to change(GroupMember, :count).by(-1)
    end

    it "keeps a member who is still enrolled" do
      synced_member("sub-1")

      expect { drop([member("sub-1")]) }.not_to change(GroupMember, :count)
    end

    it "never removes a member an instructor added by hand" do
      synced_member("sub-1", synced: false)

      expect { drop([]) }.not_to change(GroupMember, :count)
    end

    it "never removes members synced from another deployment" do
      other = FactoryBot.create(:lti_deployment)
      synced_member("sub-1", deployment_id: other.id)

      expect { drop([]) }.not_to change(GroupMember, :count)
    end

    it "leaves the user account alone" do
      synced_member("sub-1")

      expect { drop([]) }.not_to change(User, :count)
    end

    it "returns the users it removed" do
      user = synced_member("sub-1")
      synced_member("sub-2")

      expect(drop([member("sub-2")])).to eq([user])
    end

    it "drops nobody when the roster is unchanged" do
      synced_member("sub-1")
      synced_member("sub-2")

      expect(drop([member("sub-1"), member("sub-2")])).to be_empty
    end
  end
end
