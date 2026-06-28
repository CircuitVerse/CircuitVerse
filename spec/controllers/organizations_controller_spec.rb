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

    it "assigns public organizations when explore parameter is present" do
      public_org = create(:organization, private: false)
      get :index, params: { explore: "true" }
      expect(controller.instance_variable_get(:@organizations)).to include(public_org)
    end
  end

  describe "GET #show" do
    context "when user has show access" do
      before do
        create(:organization_member, user: user, organization: organization)
      end

      it "returns a success response" do
        get :show, params: { id: organization.id }
        expect(response).to be_successful
      end
    end

    context "when user does not have show access" do
      it "returns a forbidden status" do
        get :show, params: { id: organization.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    context "when user has edit access" do
      before do
        create(:organization_member, user: user, organization: organization, role: :admin)
      end

      it "returns a success response" do
        get :edit, params: { id: organization.id }
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
        expect(response).to redirect_to(Organization.last)
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
          expect(response).to redirect_to(organization)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when user has edit access" do
      before do
        create(:organization_member, user: user, organization: organization, role: :admin)
      end

      it "destroys the requested organization" do
        expect do
          delete :destroy, params: { id: organization.id }
        end.to change(Organization, :count).by(-1)
      end

      it "redirects to the organizations list" do
        delete :destroy, params: { id: organization.id }
        expect(response).to redirect_to(organizations_path)
      end
    end
  end
end
