# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyUser, type: :service do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @user)
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @project = FactoryBot.create(:project, author: @user)
    @category = FactoryBot.create(:forum_category)
    @thread = FactoryBot.create(:forum_thread, forum_category_id: @category.id, user_id: @user.id)
  end

  describe "#call" do
    describe "StarNotification" do
      before do
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @user,
          type: "StarNotification",
          params:
            { user: @user, project: @project },
          read_at: nil
        )
      end

      let(:result) { described_class.new(notification_id: @notification.id).call }

      it "returns result as success with type 'star'" do
        expect(result.success).to eq("true")
        expect(result.type).to eq("star")
      end

      it "returns project author and project as first_param and second" do
        expect(result.first_param).to eq(@notification.params[:project].author)
        expect(result.second).to eq(@notification.params[:project])
      end
    end

    describe "ForkNotification" do
      before do
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @user,
          type: "ForkNotification",
          params:
            { user: @user, project: @project },
          read_at: nil
        )
      end

      let(:result) { described_class.new(notification_id: @notification.id).call }

      it "returns result as success with type 'fork'" do
        expect(result.success).to eq("true")
        expect(result.type).to eq("fork")
      end

      it "returns project author and project as first_param and second" do
        expect(result.first_param).to eq(@notification.params[:project].author)
        expect(result.second).to eq(@notification.params[:project])
      end
    end

    describe "NewAssignmentNotification" do
      before do
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @user,
          type: "NewAssignmentNotification",
          params:
            { user: @user, assignment: @assignment },
          read_at: nil
        )
      end

      let(:result) { described_class.new(notification_id: @notification.id).call }

      it "returns result as success with type 'new_assignment'" do
        expect(result.success).to eq("true")
        expect(result.type).to eq("new_assignment")
      end

      it "returns assignment's group and assignment as first_param and second" do
        expect(result.first_param).to eq(@notification.params[:assignment].group)
        expect(result.second).to eq(@notification.params[:assignment])
      end
    end

    describe "ForumCommentNotification" do
      before do
        @post = FactoryBot.create(:forum_post, forum_thread_id: @thread.id, user_id: @user.id)
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @user,
          type: "ForumCommentNotification",
          params:
          { forum_thread: @thread, forum_post: @post },
          read_at: nil
        )
      end

      let(:result) { described_class.new(notification_id: @notification.id).call }

      it "returns result as success with type 'forum_comment'" do
        expect(result.success).to eq("true")
        expect(result.type).to eq("forum_comment")
      end

      it "returns thread and post as first_param and second" do
        expect(result.first_param).to eq(@notification.params[:forum_thread])
        expect(result.second).to eq(@notification.params[:forum_post].id)
      end
    end

    describe "ForumThreadNotification" do
      before do
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @user,
          type: "ForumThreadNotification",
          params:
            { forum_thread: @thread },
          read_at: nil
        )
      end

      let(:result) { described_class.new(notification_id: @notification.id).call }

      it "returns result as success with type 'forum_thread'" do
        expect(result.success).to eq("true")
        expect(result.type).to eq("forum_thread")
      end

      it "returns thread as first_param" do
        expect(result.first_param).to eq(@notification.params[:forum_thread])
      end
    end

    describe "No Type" do
      before do
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @user,
          type: "NoType",
          params:
            { user: @user },
          read_at: nil
        )
      end

      let(:result) { described_class.new(notification_id: @notification.id).call }

      it "returns failure with type 'no_type'" do
        expect(result.success).to eq("false")
        expect(result.type).to eq("no_type")
      end
    end
  end
end
