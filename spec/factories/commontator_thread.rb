# frozen_string_literal: true

FactoryBot.define do
  factory :commontator_thread, class: "Commontator::Thread" do
    commontable_type { "Project" }
  end
end
