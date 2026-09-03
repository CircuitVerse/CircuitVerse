# frozen_string_literal: true

require "rails_helper"

describe CommentThreadPolicy do
  subject { described_class.new(user, comment_thread) }

  let(:author)         { FactoryBot.create(:user) }
  let(:project)        { FactoryBot.create(:project, :public, author: author) }
  let(:comment_thread) { FactoryBot.create(:comment_thread, commentable: project) }

  context "when the project is public" do
    context "with an anonymous user" do
      let(:user) { nil }

      it { is_expected.to permit(:show) }
      it { is_expected.not_to permit(:create_comment) }
      it { is_expected.not_to permit(:subscribe) }
      it { is_expected.not_to permit(:close) }
    end

    context "with a signed in user" do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to permit(:show) }
      it { is_expected.to permit(:create_comment) }
      it { is_expected.to permit(:subscribe) }
      it { is_expected.not_to permit(:close) }
    end

    context "with a site admin" do
      let(:user) { FactoryBot.create(:user, admin: true) }

      it { is_expected.to permit(:close) }
      it { is_expected.to permit(:reopen) }
    end
  end

  context "when the project is private" do
    let(:project) { FactoryBot.create(:project, author: author) }

    context "with an anonymous user" do
      let(:user) { nil }

      it { is_expected.not_to permit(:show) }
    end

    context "with an unrelated user" do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.not_to permit(:show) }
      it { is_expected.not_to permit(:create_comment) }
    end

    context "with the project author" do
      let(:user) { author }

      it { is_expected.to permit(:show) }
      it { is_expected.to permit(:create_comment) }
    end
  end

  context "when the thread is closed" do
    let(:user) { FactoryBot.create(:user) }

    before { comment_thread.close!(FactoryBot.create(:user, admin: true)) }

    it { is_expected.to permit(:show) }
    it { is_expected.not_to permit(:create_comment) }
  end
end
