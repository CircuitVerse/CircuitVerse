# frozen_string_literal: true

require "rails_helper"

describe Users::NoticedNotificationsController, type: :request do
  before do
    @owner = FactoryBot.create(:user)
    @other_user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @owner)
  end

  describe "#index" do
    before do
      @notification = FactoryBot.create(
        :noticed_notification,
        recipient: @owner,
        params: { user: @other_user, project: @project },
        read_at: nil
      )
    end

    it "gets the notifications for the owner" do
      sign_in @owner
      get notifications_path(@owner)
      expect(@owner.noticed_notifications.count).to eq(1)
      expect(@owner.noticed_notifications.unread.count).to eq(1)
    end
  end

  describe "#mark_as_read" do
    before do
      @notification = FactoryBot.create(
        :noticed_notification,
        recipient: @owner,
        params: { user: @other_user, project: @project },
        read_at: nil
      )
    end

    context "when owner marks their own notification" do
      it "marks notification as read" do
        sign_in @owner
        post mark_as_read_path(id: @owner.id, notification_id: @notification)
        expect(@owner.noticed_notifications.read.count).to eq(1)
      end
    end

    context "when another user tries to mark notification (IDOR protection)" do
      it "does not mark notification as read and redirects with error" do
        sign_in @other_user
        expect do
          post mark_as_read_path(id: @owner.id, notification_id: @notification)
        end.not_to(change { @notification.reload.read_at })
        expect(response).to redirect_to(notifications_path(@other_user))
        expect(flash[:alert]).to eq(I18n.t("notifications.not_found"))
      end
    end

    context "when user is not authenticated" do
      it "requires authentication" do
        post mark_as_read_path(id: @owner.id, notification_id: @notification)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#mark_all_as_read" do
    before do
      @notification = FactoryBot.create(
        :noticed_notification,
        recipient: @owner,
        params: { user: @other_user, project: @project },
        read_at: nil
      )
    end

    context "when owner marks all notifications as read" do
      it "marks all notifications as read" do
        sign_in @owner
        patch mark_all_as_read_path(id: @owner.id)
        expect(@owner.noticed_notifications.read.count).to eq(1)
      end
    end

    context "when another user tries to mark all (IDOR protection)" do
      it "does not mark owner's notifications" do
        sign_in @other_user
        patch mark_all_as_read_path(id: @owner.id)
        expect(response).to have_http_status(:redirect)
        expect(@owner.noticed_notifications.unread.count).to eq(1)
      end
    end
  end
end
