# frozen_string_literal: true

require "rails_helper"

describe CommentThreadsController, type: :request do
  let(:project) { FactoryBot.create(:project, project_access_type: "Public") }
  let(:thread) { project.comment_thread }

  it "forbids close/reopen for non-admins" do
    sign_in FactoryBot.create(:user)
    patch close_comment_thread_path(thread)
    expect(response).to have_http_status(:forbidden)
    patch reopen_comment_thread_path(thread)
    expect(response).to have_http_status(:forbidden)
  end

  it "closes and reopens for admins" do
    sign_in FactoryBot.create(:user, :admin)
    patch close_comment_thread_path(thread)
    expect(thread.reload.is_closed?).to be true
    patch reopen_comment_thread_path(thread)
    expect(thread.reload.is_closed?).to be false
  end

  it "renders the thread on the project page when enabled" do
    flipper_enable(:project_comments)
    author = project.author
    FactoryBot.create(:comment, thread: thread, creator: author, body: "visible body")
    get user_project_path(author, project)
    expect(response.body).to include("comments-container")
    expect(response.body).to include("visible body")
  end
end
