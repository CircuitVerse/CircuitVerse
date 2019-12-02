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
      emails: "#{@new_collaboration.email} #{@user.email}" } }
    end

    context "author is logged in", :focus do
      before do
        FactoryBot.create(:collaboration, project: @project, user: @user)
        sign_in @author
      end

      it "creates collaboration" do
        expect(Utils).to receive(:mail_notice)
        expect {
          post collaborations_path, params: create_params
        }.to change { Collaboration.count }.by(1)
      end
    end

    context "author is not logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        post collaborations_path(@project), params: create_params
        check_not_authorized(response)
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
        expect {
          delete collaboration_path(@collaboration)
        }.to change { Collaboration.count }.by(-1)
      end
    end

    context "user other than author is logged in" do
      it "throws unauthorized error" do
        sign_in_random_user
        delete collaboration_path(@collaboration)
        check_not_authorized(response)
      end
    end
  end

  describe "#udpate" do
    before do
      @new_project = FactoryBot.create(:project)
      @collaboration = FactoryBot.create(:collaboration, project: @project,
        user: FactoryBot.create(:user))
    end

    let(:update_params) {
      {
        collaboration: {
          project_id: @new_project.id
        }
      }
    }

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
  end
end
