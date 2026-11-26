# frozen_string_literal: true

require "rails_helper"

describe CollaborationPolicy do
  subject { described_class.new(user, @collaboration) }

  before do
    @author = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @author)
    @collaborator = FactoryBot.create(:user)
    @collaboration = FactoryBot.create(:collaboration, project: @project, user: @collaborator)
  end

  context "when the user is the project author" do
    let(:user) { @author }

    it { is_expected.to permit(:destroy) }
  end

  context "when the user is an admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }

    it { is_expected.to permit(:destroy) }
  end

  context "when the user is the collaborator themselves" do
    let(:user) { @collaborator }

    it { is_expected.to permit(:destroy) }
  end

  context "when the user is another collaborator on the same project" do
    let(:user) { FactoryBot.create(:collaboration, project: @project, user: FactoryBot.create(:user)).user }

    it { is_expected.not_to permit(:destroy) }
  end
end
