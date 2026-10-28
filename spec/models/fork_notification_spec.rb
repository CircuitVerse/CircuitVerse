# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForkNotification, type: :model do
  subject(:notif) { described_class.with(user: user, project: project) }

  let(:user) { create(:user) }
  let(:project) { create(:project, author: user) }

  it "personalises the message" do
    expect(notif.message).to include(user.name)
    expect(notif.message).to include(project.name)
  end

  it "handles empty or non-hash params gracefully" do
    notification = described_class.new
    expect { notification.message }.not_to raise_error
  end

  it { expect(notif.icon).to eq("fas fa-code-branch") }
end
