# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestNotification, type: :model do
  subject(:notif) { described_class.new }

  it { expect(notif.message).to eq("New Contest in CircuitVerse, Check it out.") }
  it { expect(notif.icon).to eq("fa fa-trophy") }
end
