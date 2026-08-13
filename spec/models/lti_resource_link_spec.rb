# frozen_string_literal: true

require "rails_helper"

RSpec.describe LtiResourceLink, type: :model do
  subject { FactoryBot.create(:lti_resource_link) }

  describe "associations" do
    it { is_expected.to belong_to(:lti_deployment) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:resource_link_id) }
    it { is_expected.to validate_uniqueness_of(:resource_link_id).scoped_to(:lti_deployment_id) }
  end

  describe "link uniqueness within a deployment" do
    it "rejects a duplicate resource_link_id for the same deployment" do
      existing = FactoryBot.create(:lti_resource_link)
      duplicate = FactoryBot.build(:lti_resource_link,
                                   lti_deployment: existing.lti_deployment,
                                   resource_link_id: existing.resource_link_id)
      expect(duplicate).not_to be_valid
    end

    it "allows the same resource_link_id under a different deployment" do
      existing = FactoryBot.create(:lti_resource_link)
      other = FactoryBot.build(:lti_resource_link, resource_link_id: existing.resource_link_id)
      expect(other).to be_valid
    end
  end

  describe "service endpoints from the launch claims" do
    it "stores the AGS and NRPS urls the later phases call" do
      link = FactoryBot.create(:lti_resource_link)

      expect(link).to have_attributes(
        lineitems_url: a_string_including("line_items"),
        lineitem_url: a_string_including("line_items/1"),
        context_memberships_url: a_string_including("names_and_roles")
      )
    end

    it "is valid without any service urls, since a platform may offer neither" do
      link = FactoryBot.build(:lti_resource_link, lineitems_url: nil, lineitem_url: nil,
                                                  context_memberships_url: nil)
      expect(link).to be_valid
    end
  end
end
