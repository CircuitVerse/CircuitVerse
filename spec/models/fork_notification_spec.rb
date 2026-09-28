# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForkNotification, type: :model do
  let(:author) { FactoryBot.create(:user, name: "Author User") }
  let(:forker) { FactoryBot.create(:user, name: "Forker User") }
  let(:project) { FactoryBot.create(:project, author: author, name: "Original Project") }

  describe "#message" do
    it "renders the message when params has user and project objects" do
      notif = described_class.new(user: forker, project: project)
      expect(notif.message).to eq("#{forker.name} has forked your project #{project.name}")
    end

    it "renders the message when params has user_id and project_id" do
      notif = described_class.new(user_id: forker.id, project_id: project.id)
      expect(notif.message).to eq("#{forker.name} has forked your project #{project.name}")
    end

    it "safely handles array or invalid params without raising TypeError" do
      notif = described_class.new
      allow(notif).to receive(:params).and_return([forker, project])
      expect { notif.message }.not_to raise_error
    end
  end

  describe "#icon" do
    it "returns the branch icon" do
      expect(described_class.new.icon).to eq("fas fa-code-branch")
    end
  end
end
