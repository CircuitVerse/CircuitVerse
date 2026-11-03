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

  describe "POST #create (invite by email)" do
    before { Flipper.enable(:organizations) }

    context "as an admin" do
      before { sign_in admin }

      it "adds an existing user with the chosen role" do
        existing = FactoryBot.create(:user)
        post organization_organization_members_path(organization),
             params: { organization_member: { role: "mentor", emails: [existing.email] } }
        expect(organization.organization_members.find_by(user: existing).role).to eq("mentor")
      end

      it "creates a pending invitation for a new email" do
        expect do
          post organization_organization_members_path(organization),
               params: { organization_member: { role: "member", emails: ["new@example.com"] } }
        end.to change(PendingInvitation, :count).by(1)
        invite = PendingInvitation.last
        expect(invite.organization_id).to eq(organization.id)
        expect(invite.role).to eq(OrganizationMember.roles["member"])
      end

      it "ignores invalid emails" do
        post organization_organization_members_path(organization),
             params: { organization_member: { role: "member", emails: ["notanemail"] } }
        expect(PendingInvitation.count).to eq(0)
      end

      it "does not duplicate an existing member" do
        existing = FactoryBot.create(:organization_member, organization: organization, role: :member)
        expect do
          post organization_organization_members_path(organization),
               params: { organization_member: { role: "mentor", emails: [existing.user.email] } }
        end.not_to(change { organization.organization_members.count })
      end
    end
  end

  context "as a non-admin" do
    it "forbids inviting" do
      member = FactoryBot.create(:organization_member, organization: organization, role: :member)
      sign_in member.user
      post organization_organization_members_path(organization),
           params: { organization_member: { role: "member", emails: ["x@example.com"] } }
      expect(response).to have_http_status(:forbidden)
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
