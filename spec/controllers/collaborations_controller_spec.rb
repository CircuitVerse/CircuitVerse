# frozen_string_literal: true

require "rails_helper"

describe CollaborationsController, type: :request do
  before do
    @author = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @author)
  end

  describe "#create" do
    before do
      @new_collaboration = FactoryBot.create(:user)
      @user = FactoryBot.create(:user)
    end

    let(:create_params) do
      { collaboration:
      { project_id: @project.id,
        emails: [@new_collaboration.email, @user.email] } }
    end

    context "author is logged in" do
      before do
        FactoryBot.create(:collaboration, project: @project, user: @user)
        sign_in @author
      end

      it "creates collaboration" do
        expect(Utils).to receive(:mail_notice)
        expect do
          post collaborations_path, params: create_params
        end.to change(Collaboration, :count).by(1)
      end
    end

    context "author is not logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        post collaborations_path(@project), params: create_params
        check_not_authorized(response)
      end
    end

    context "when no user is signed in" do
      it "redirects to sign in instead of authorizing" do
        post collaborations_path, params: create_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create a collaboration" do
        expect do
          post collaborations_path, params: create_params
        end.not_to change(Collaboration, :count)
      end
    end
  end

  describe "#destroy" do
    before do
      user = FactoryBot.create(:user)
      @collaboration = FactoryBot.create(:collaboration, project: @project, user: user)
    end

    context "author of project is logged in" do
      it "destroys collaboration" do
        sign_in @author
        expect do
          delete collaboration_path(@collaboration)
        end.to change(Collaboration, :count).by(-1)
      end
    end

    context "user other than author is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        delete collaboration_path(@collaboration)
        check_not_authorized(response)
      end
    end

    context "when no user is signed in" do
      it "redirects to sign in instead of authorizing" do
        delete collaboration_path(@collaboration)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not destroy the collaboration" do
        expect do
          delete collaboration_path(@collaboration)
        end.not_to change(Collaboration, :count)
      end
    end
  end

  describe "#update" do
    before do
      @new_project = FactoryBot.create(:project)
      @collaboration = FactoryBot.create(:collaboration, project: @project,
                                                         user: FactoryBot.create(:user))
    end

    let(:update_params) do
      {
        collaboration: {
          project_id: @new_project.id
        }
      }
    end

    context "author is signed in" do
      it "updates the collaboration" do
        sign_in @author
        put collaboration_path(@collaboration), params: update_params
        @collaboration.reload
        expect(@collaboration.project_id).to eq(@new_project.id)
      end
    end

    context "user other than author is signed_in" do
      it "throws unauthorized error" do
        sign_in_random_user
        put collaboration_path(@collaboration), params: update_params
        check_not_authorized(response)
      end
    end

    context "when no user is signed in" do
      it "redirects to sign in instead of authorizing" do
        put collaboration_path(@collaboration), params: update_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not update the collaboration" do
        expect do
          put collaboration_path(@collaboration), params: update_params
        end.not_to change { @collaboration.reload.project_id }
      end
    end
  end
end
