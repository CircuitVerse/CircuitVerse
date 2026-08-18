# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization invite and member management", type: :request do
  let(:admin) { FactoryBot.create(:user) }
  let(:mentor) { FactoryBot.create(:user) }
  let(:member) { FactoryBot.create(:user) }
  let(:outsider) { FactoryBot.create(:user) }
  let(:organization) { FactoryBot.create(:organization) }

  before do
    FactoryBot.create(:organization_member, organization: organization, user: admin, role: :admin)
    Flipper.enable(:organizations)
  end

  describe "GET #members" do
    before do
      FactoryBot.create(:organization_member, organization: organization, user: mentor, role: :mentor)
      FactoryBot.create(:organization_member, organization: organization, user: member, role: :member)
    end

    it "renders the members page for an admin" do
      sign_in admin
      get members_organization_path(organization)
      expect(response).to have_http_status(:ok)
    end

    it "sorts by name ascending" do
      sign_in admin
      get members_organization_path(organization, sort: "name", direction: "asc")
      expect(response).to have_http_status(:ok)
    end

    it "sorts by role" do
      sign_in admin
      get members_organization_path(organization, sort: "role", direction: "desc")
      expect(response).to have_http_status(:ok)
    end

    it "sorts by joined date" do
      sign_in admin
      get members_organization_path(organization, sort: "created_at", direction: "asc")
      expect(response).to have_http_status(:ok)
    end

    it "ignores an invalid sort column" do
      sign_in admin
      get members_organization_path(organization, sort: "malicious'; DROP TABLE users; --")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update (role change)" do
    let!(:target) { FactoryBot.create(:organization_member, organization: organization, user: member, role: :member) }

    it "lets an admin change a member's role" do
      sign_in admin
      patch organization_organization_member_path(organization, target),
            params: { organization_member: { role: "mentor" } }
      expect(target.reload.role).to eq("mentor")
    end

    it "forbids a non-admin from changing roles" do
      FactoryBot.create(:organization_member, organization: organization, user: mentor, role: :mentor)
      sign_in mentor
      patch organization_organization_member_path(organization, target),
            params: { organization_member: { role: "admin" } }
      expect(target.reload.role).to eq("member")
    end

    it "does not allow demoting the sole admin" do
      admin_member = organization.organization_members.find_by(user: admin)
      sign_in admin
      patch organization_organization_member_path(organization, admin_member),
            params: { organization_member: { role: "member" } }
      expect(admin_member.reload.role).to eq("admin")
    end
  end

  describe "DELETE #destroy (remove member)" do
    let!(:target) { FactoryBot.create(:organization_member, organization: organization, user: member, role: :member) }

    it "lets an admin remove a member" do
      sign_in admin
      expect do
        delete organization_organization_member_path(organization, target)
      end.to change { organization.organization_members.where(user: member).count }.by(-1)
    end

    it "forbids a non-admin from removing members" do
      FactoryBot.create(:organization_member, organization: organization, user: mentor, role: :mentor)
      sign_in mentor
      expect do
        delete organization_organization_member_path(organization, target)
      end.not_to(change { organization.organization_members.where(user: member).count })
    end

    it "does not allow removing the sole admin" do
      admin_member = organization.organization_members.find_by(user: admin)
      sign_in admin
      expect do
        delete organization_organization_member_path(organization, admin_member)
      end.not_to(change { organization.organization_members.where(user: admin).count })
    end
  end
end
