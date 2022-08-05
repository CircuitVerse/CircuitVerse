# frozen_string_literal: true

require "rails_helper"

RSpec.describe NoticedNotification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  describe "associations" do
    it { is_expected.to belong_to(:recipient) }
  end
end
