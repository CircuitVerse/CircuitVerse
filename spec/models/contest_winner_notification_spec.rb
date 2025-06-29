# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestWinnerNotification, type: :model do
  subject(:notif) { described_class.with(project: project) }

  let(:project) { create(:project) }

  it "personalises the message" do
    expect(notif.message).to include(project.name)
  end

  it { expect(notif.icon).to eq("fa fa-trophy") }
end
