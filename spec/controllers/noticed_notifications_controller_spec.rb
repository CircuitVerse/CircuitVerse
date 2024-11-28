# frozen_string_literal: true

require "rails_helper"

describe Users::NoticedNotificationsController, type: :request do
  before do
    @author = create(:user)
    @user = sign_in_random_user
    @project = create(:project, author: @author)
  end

  describe "#index" do
    before do
      @notification = create(
        :noticed_notification,
        recipient: @author,
        params:
          { user: @user, project: @project },
        read_at: nil
      )
    end

    it "get the notifications" do
      get notifications_path(@author)
      expect(@author.noticed_notifications.count).to eq(1)
      expect(@author.noticed_notifications.unread.count).to eq(1)
    end
  end

  describe "#mark_as_read" do
    before do
      @notification = create(
        :noticed_notification,
        recipient: @author,
        params:
          { user: @user, project: @project },
        read_at: nil
      )
    end

    it "mark notification as read" do
      post mark_as_read_path(id: @author.id, notification_id: @notification)
      expect(@author.noticed_notifications.read.count).to eq(1)
    end
  end

  describe "#mark_all_as_read" do
    before do
      @notification = create(
        :noticed_notification,
        recipient: @author,
        params:
          { user: @user, project: @project },
        read_at: nil
      )
    end

    it "mark all notifications as read" do
      sign_in @author
      patch mark_all_as_read_path(id: @author.id, notification_id: @notification)
      expect(@author.noticed_notifications.read.count).to eq(1)
    end
  end
end
