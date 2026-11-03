# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationsController, type: :controller do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    Flipper.enable(:organizations)
    sign_in user
  end

  context "when feature flag is disabled" do
    before do
      Flipper.disable(:organizations)
    end

    it "redirects to root" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  context "when user is not logged in" do
    before do
      sign_out user
    end

    it "redirects to login" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @organizations with user's organizations" do
      create(:organization_member, user: user, organization: organization)
      get :index
      expect(controller.instance_variable_get(:@organizations)).to include(organization)
    end
  end

  describe "GET #show" do
    context "when user has show access" do
      before do
        create(:organization_member, user: user, organization: organization)
      end

      it "redirects to the overview tab" do
        get :show, params: { id: organization.id }
        expect(response).to redirect_to(overview_organization_path(organization))
      end
    end

    context "when user does not have show access" do
      it "raises a not found error" do
        expect do
          get :show, params: { id: organization.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET #switcher_organizations" do
    it "clamps a negative page to the first page" do
      get :switcher_organizations, params: { page: -1 }, format: :json

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #overview group visibility" do
    let(:other_mentor) { create(:user) }
    let!(:group_user_is_in) { create(:group, organization: organization, primary_mentor: other_mentor) }
    let!(:other_group) { create(:group, organization: organization, primary_mentor: other_mentor) }

    context "when the user is an org admin" do
      before do
        create(:organization_member, organization: organization, user: user, role: :admin)
      end

      it "shows all groups in the organization" do
        get :overview, params: { id: organization.id }
        visible = controller.instance_variable_get(:@groups)
        expect(visible).to include(group_user_is_in, other_group)
      end
    end

    context "when the user is a member of only one group" do
      before do
        create(:organization_member, organization: organization, user: user, role: :member)
        create(:group_member, user: user, group: group_user_is_in)
      end

      it "shows only the groups the user belongs to" do
        get :overview, params: { id: organization.id }
        visible = controller.instance_variable_get(:@groups)
        expect(visible).to include(group_user_is_in)
        expect(visible).not_to include(other_group)
      end
    end

    context "when the user is a mentor who owns a group" do
      let!(:owned_group) { create(:group, organization: organization, primary_mentor: user) }

      before do
        create(:organization_member, organization: organization, user: user, role: :mentor)
      end

      it "shows groups they own but not groups they are not part of" do
        get :overview, params: { id: organization.id }
        visible = controller.instance_variable_get(:@groups)
        expect(visible).to include(owned_group)
        expect(visible).not_to include(other_group)
      end
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #settings" do
    context "when user has edit access" do
      before do
        create(:organization_member, user: user, organization: organization, role: :admin)
      end

      it "returns a success response" do
        get :settings, params: { id: organization.id }
        expect(response).to be_successful
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_attributes) { { name: "New Org" } }

      it "creates a new Organization" do
        expect do
          post :create, params: { organization: valid_attributes }
        end.to change(Organization, :count).by(1)
      end

      it "creates an admin member for the current user" do
        post :create, params: { organization: valid_attributes }
        org = Organization.last
        expect(org.organization_members.where(user: user, role: "admin")).to exist
      end

      it "redirects to the created organization" do
        post :create, params: { organization: valid_attributes }
        expect(response).to redirect_to(overview_organization_path(Organization.last))
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { name: "" } } # Assuming name is required

      it "returns an unprocessable_content response" do
        post :create, params: { organization: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH #update" do
    context "when user has edit access" do
      before do
        create(:organization_member, user: user, organization: organization, role: :admin)
      end

      context "with valid params" do
        let(:new_attributes) { { name: "Updated Org" } }

        it "updates the requested organization" do
          patch :update, params: { id: organization.id, organization: new_attributes }
          organization.reload
          expect(organization.name).to eq("Updated Org")
        end

        it "redirects to the organization" do
          patch :update, params: { id: organization.id, organization: new_attributes }
          expect(response).to redirect_to(overview_organization_path(organization))
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when user has edit access" do
      before do
        create(:organization_member, user: user, organization: organization, role: :admin)
      end

      context "when confirmation matches the organization name" do
        it "destroys the requested organization" do
          expect do
            delete :destroy, params: { id: organization.id, confirmation: organization.name }
          end.to change(Organization, :count).by(-1)
        end

        it "redirects to the organizations list" do
          delete :destroy, params: { id: organization.id, confirmation: organization.name }
          expect(response).to redirect_to(organizations_path)
        end
      end

      context "when confirmation does not match the organization name" do
        it "does not destroy the organization" do
          expect do
            delete :destroy, params: { id: organization.id, confirmation: "wrong name" }
          end.not_to change(Organization, :count)
        end

        it "redirects back to the settings page" do
          delete :destroy, params: { id: organization.id, confirmation: "wrong name" }
          expect(response).to redirect_to(settings_organization_path(organization))
        end
      end

      context "when confirmation is missing" do
        it "does not destroy the organization" do
          expect do
            delete :destroy, params: { id: organization.id }
          end.not_to change(Organization, :count)
        end
      end

      context "when confirmation does not match (JSON)" do
        it "returns an unprocessable_content error" do
          expect do
            delete :destroy, params: { id: organization.id, confirmation: "wrong" }, format: :json
          end.not_to change(Organization, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.media_type).to eq("application/json")
          expect(response.parsed_body).to include("error")
        end
      end
    end
  end
end
