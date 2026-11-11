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

    context "author is logged in and the project belongs to an assignment" do
      before do
        @group = FactoryBot.create(:group, primary_mentor: @author)
        @assignment = FactoryBot.create(:assignment, group: @group,
                                                     name: "Lab 1", deadline: 3.days.from_now)
        @project.update!(assignment: @assignment)
        @collaboration = FactoryBot.create(:collaboration, project: @project, user: @user)
        sign_in @author
      end

      it "notifies the added collaborator about the assignment" do
        expect do
          post collaborations_path, params: create_params
        end.to change(NoticedNotification, :count).by(1)

        notification = NoticedNotification.order(:created_at).last
        expect(notification.type).to eq("AssignmentCollaboratorNotification")
        expect(notification.recipient).to eq(@new_collaboration)
        expect(notification.params[:assignment]).to eq(@assignment)
        expect(notification.params[:user]).to eq(@author)
      end

      it "does not notify anyone when the collaboration already exists" do
        post collaborations_path, params: { collaboration: { project_id: @project.id,
                                                             emails: [@user.email] } }
        expect(NoticedNotification.where(type: "AssignmentCollaboratorNotification").count).to eq(0)
      end
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
  end

  describe "#update" do
    before do
      @collaboration = FactoryBot.create(:collaboration, project: @project,
                                                         user: FactoryBot.create(:user))
    end

    it "is not routable" do
      expect do
        Rails.application.routes.recognize_path(
          collaboration_path(@collaboration), method: :patch
        )
      end.to raise_error(ActionController::RoutingError)
    end
  end
end
