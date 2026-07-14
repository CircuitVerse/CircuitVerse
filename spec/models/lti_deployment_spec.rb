# frozen_string_literal: true

require "rails_helper"

RSpec.describe LtiDeployment, type: :model do
  subject { FactoryBot.create(:lti_deployment) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:issuer) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:deployment_id) }
    it { is_expected.to validate_presence_of(:auth_login_url) }
    it { is_expected.to validate_presence_of(:access_token_url) }
    it { is_expected.to validate_presence_of(:jwks_url) }

    it { is_expected.to validate_uniqueness_of(:deployment_id).scoped_to(:issuer, :client_id) }
  end

  describe "deployment uniqueness across platforms" do
    it "rejects a duplicate deployment_id for the same issuer and client" do
      existing = FactoryBot.create(:lti_deployment)
      duplicate = FactoryBot.build(:lti_deployment,
                                   issuer: existing.issuer,
                                   client_id: existing.client_id,
                                   deployment_id: existing.deployment_id)
      expect(duplicate).not_to be_valid
    end

    it "allows the same deployment_id under a different issuer" do
      existing = FactoryBot.create(:lti_deployment)
      other_platform = FactoryBot.build(:lti_deployment,
                                        deployment_id: existing.deployment_id)
      expect(other_platform).to be_valid
    end

    it "allows the same deployment_id under a different client of the same issuer" do
      existing = FactoryBot.create(:lti_deployment)
      other_client = FactoryBot.build(:lti_deployment,
                                      issuer: existing.issuer,
                                      deployment_id: existing.deployment_id)
      expect(other_client).to be_valid
    end
  end
end
