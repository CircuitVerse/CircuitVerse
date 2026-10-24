# frozen_string_literal: true

require "rails_helper"

RSpec.describe NoticedNotification, type: :model do
  describe ".noticed_coder" do
    it "uses the jsonb coder even when the database is unavailable" do
      allow(described_class).to receive(:table_exists?).and_raise(ActiveRecord::ConnectionNotEstablished)

      expect(described_class.noticed_coder).to eq(Noticed::Coder)
    end
  end

  describe "params" do
    let(:recipient) { create(:user) }
    let(:project) { create(:project) }

    it "is deserialized with Noticed::Coder" do
      expect(described_class.type_for_attribute(:params).coder.coder).to eq(Noticed::Coder)
    end

    it "round-trips through the database and renders" do
      notification = create(
        :noticed_notification,
        type: "ContestWinnerNotification",
        recipient: recipient,
        params: { project: project }
      )

      expect(described_class.find(notification.id).to_notification.message).to include(project.name)
    end
  end
end
