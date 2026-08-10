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

  describe "PUT #generate_invite_token" do
    it "generates a token with the chosen role for an admin" do
      sign_in admin
      put generate_invite_token_organization_path(organization, role: "mentor")
      organization.reload
      expect(organization.invite_token).to be_present
      expect(organization.invite_token_role).to eq(OrganizationMember.roles["mentor"])
    end

    it "defaults to member role for an invalid role param" do
      sign_in admin
      put generate_invite_token_organization_path(organization, role: "superadmin")
      organization.reload
      expect(organization.invite_token_role).to eq(OrganizationMember.roles["member"])
    end

    it "forbids a non-admin from generating a token" do
      FactoryBot.create(:organization_member, organization: organization, user: member, role: :member)
      sign_in member
      put generate_invite_token_organization_path(organization, role: "admin")
      expect(response).to have_http_status(:forbidden)
    end

    it "forbids a non-member from generating a token" do
      sign_in outsider
      put generate_invite_token_organization_path(organization, role: "member")
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET #confirm_join" do
    before { organization.reset_invite_token(role: :admin) }

    it "does not create membership on GET" do
      sign_in outsider
      expect do
        get confirm_join_organization_path(organization, token: organization.invite_token)
      end.not_to change(OrganizationMember, :count)
    end

    it "redirects for an expired token" do
      organization.reset_invite_token(role: :member)
      organization.update!(invite_token_expires_at: 1.day.ago)
      sign_in outsider
      get confirm_join_organization_path(organization, token: organization.invite_token)
      expect(response).to redirect_to(root_path)
    end

    it "renders the confirmation page for a valid token" do
      sign_in outsider
      get confirm_join_organization_path(organization, token: organization.invite_token)
      expect(response).to have_http_status(:ok)
    end

    it "redirects for an invalid token" do
      sign_in outsider
      get confirm_join_organization_path(organization, token: "wrongtoken")
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #join" do
    context "with a valid invite token" do
      before { organization.reset_invite_token(role: :mentor) }

      it "adds the user with the token's role" do
        sign_in outsider
        expect do
          post join_organization_path(organization, token: organization.invite_token)
        end.to change { organization.organization_members.where(user: outsider).count }.by(1)
        expect(organization.organization_members.find_by(user: outsider).role).to eq("mentor")
      end

      it "does not duplicate membership for an existing member" do
        FactoryBot.create(:organization_member, organization: organization, user: outsider, role: :member)
        sign_in outsider
        expect do
          post join_organization_path(organization, token: organization.invite_token)
        end.not_to(change { organization.organization_members.where(user: outsider).count })
      end

      it "keeps the existing role for an existing member" do
        FactoryBot.create(:organization_member, organization: organization, user: outsider, role: :admin)
        sign_in outsider
        post join_organization_path(organization, token: organization.invite_token)
        expect(organization.organization_members.find_by(user: outsider).role).to eq("admin")
      end
    end

    context "with an expired token" do
      before do
        organization.reset_invite_token(role: :member)
        organization.update!(invite_token_expires_at: 1.day.ago)
      end

      it "does not add the user" do
        sign_in outsider
        expect do
          post join_organization_path(organization, token: organization.invite_token)
        end.not_to change(OrganizationMember, :count)
      end
    end

    context "with an invalid token" do
      before { organization.reset_invite_token(role: :member) }

      it "does not add the user" do
        sign_in outsider
        expect do
          post join_organization_path(organization, token: "wrongtoken")
        end.not_to change(OrganizationMember, :count)
      end
    end

    context "with a token belonging to a different organization" do
      let(:other_org) { FactoryBot.create(:organization) }

      before { other_org.reset_invite_token(role: :admin) }

      it "does not add the user to this organization" do
        sign_in outsider
        expect do
          post join_organization_path(organization, token: other_org.invite_token)
        end.not_to(change { organization.organization_members.where(user: outsider).count })
      end
    end

    context "when the token was regenerated with a different role" do
      it "does not grant the new role through an old token" do
        organization.reset_invite_token(role: :member)
        old_token = organization.invite_token
        organization.reset_invite_token(role: :admin)

        sign_in outsider
        expect do
          post join_organization_path(organization, token: old_token)
        end.not_to change(OrganizationMember, :count)
      end
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
