# frozen_string_literal: true

require "rails_helper"

RSpec.describe NoticedNotification, type: :model do
  describe ".noticed_coder" do
    it "does not depend on the database being available" do
      allow(described_class).to receive(:table_exists?).and_raise(ActiveRecord::ConnectionNotEstablished)

      expect(described_class.noticed_coder).to eq(described_class::ParamsCoder)
    end
  end

  describe "params" do
    let(:recipient) { create(:user) }
    let(:project) { create(:project) }
    let(:notification) do
      create(
        :noticed_notification,
        type: "ContestWinnerNotification",
        recipient: recipient,
        params: { project: project }
      )
    end

    it "is deserialized with ParamsCoder" do
      expect(described_class.type_for_attribute(:params).coder).to eq(described_class::ParamsCoder)
    end

    it "round-trips through the database and renders" do
      expect(described_class.find(notification.id).to_notification.message).to include(project.name)
    end

    it "still renders rows stored as a JSON string by Noticed::TextCoder" do
      legacy_params = Noticed::TextCoder.dump({ project: project })
      sql = ["params = to_jsonb(?::text)", legacy_params]
      described_class.where(id: notification.id).update_all(sql) # rubocop:disable Rails/SkipsModelValidations

      expect(described_class.find(notification.id).to_notification.message).to include(project.name)
    end
  end
end
