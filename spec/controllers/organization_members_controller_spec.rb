# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationMembersController, type: :controller do
  let(:admin_user) { create(:user) }
  let(:target_user) { create(:user) }
  let(:organization) { create(:organization) }
  let!(:admin_member) { create(:organization_member, user: admin_user, organization: organization, role: :admin) }

  before do
    Flipper.enable(:organizations)
    sign_in admin_user
  end

  context "when feature flag is disabled" do
    before do
      Flipper.disable(:organizations)
    end

    it "redirects to root" do
      get :create, params: { organization_id: organization.id }
      expect(response).to redirect_to(root_path)
    end
  end

  context "when user is not logged in" do
    before do
      sign_out admin_user
    end

    it "redirects to login" do
      get :create, params: { organization_id: organization.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST #create" do
    context "when user has admin access" do
      let(:valid_attributes) { { user_id: target_user.id, role: "member" } }

      it "creates a new OrganizationMember" do
        expect do
          post :create, params: { organization_id: organization.id, organization_member: valid_attributes }
        end.to change(OrganizationMember, :count).by(1)
      end

      it "redirects to the organization" do
        post :create, params: { organization_id: organization.id, organization_member: valid_attributes }
        expect(response).to redirect_to(organization)
      end
    end

    context "when user does not have admin access" do
      let(:non_admin) { create(:user) }

      before do
        sign_in non_admin
        create(:organization_member, user: non_admin, organization: organization, role: :member)
      end

      it "returns a forbidden status" do
        post :create,
             params: { organization_id: organization.id,
                       organization_member: { user_id: target_user.id, role: "member" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH #update" do
    let!(:target_member) { create(:organization_member, user: target_user, organization: organization, role: :member) }

    context "when user has admin access" do
      let(:new_attributes) { { role: "mentor" } }

      it "updates the requested member" do
        patch :update,
              params: { organization_id: organization.id, id: target_member.id, organization_member: new_attributes }
        target_member.reload
        expect(target_member.role).to eq("mentor")
      end

      it "redirects to the organization" do
        patch :update,
              params: { organization_id: organization.id, id: target_member.id, organization_member: new_attributes }
        expect(response).to redirect_to(organization)
      end

      it "returns a forbidden status when demoting sole admin" do
        # Make target_member an admin and the only admin
        admin_member.destroy
        target_member.update!(role: :admin)

        # Let's make sure the target user is signed in to demote themselves
        sign_in target_user

        patch :update,
              params: { organization_id: organization.id, id: target_member.id,
                        organization_member: { role: "member" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:target_member) { create(:organization_member, user: target_user, organization: organization, role: :member) }

    context "when user has admin access" do
      it "destroys the requested member" do
        expect do
          delete :destroy, params: { organization_id: organization.id, id: target_member.id }
        end.to change(OrganizationMember, :count).by(-1)
      end

      it "redirects to the organization" do
        delete :destroy, params: { organization_id: organization.id, id: target_member.id }
        expect(response).to redirect_to(organization)
      end
    end

    context "when user is a mentor trying to destroy another member" do
      before do
        mentor_user = create(:user)
        create(:organization_member, user: mentor_user, organization: organization, role: :mentor)
        sign_in mentor_user
      end

      it "returns a forbidden status" do
        delete :destroy, params: { organization_id: organization.id, id: target_member.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE #leave" do
    context "when user is a member" do
      let(:member_user) { create(:user) }

      before do
        create(:organization_member, user: member_user, organization: organization, role: :member)
        sign_in member_user
      end

      it "destroys their own membership" do
        expect do
          delete :leave, params: { organization_id: organization.id }
        end.to change(OrganizationMember, :count).by(-1)
      end

      it "redirects to organizations list" do
        delete :leave, params: { organization_id: organization.id }
        expect(response).to redirect_to(organizations_path)
      end
    end

    context "when user is the sole admin" do
      it "returns a forbidden status" do
        delete :leave, params: { organization_id: organization.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
