FactoryBot.define do
  factory :notification, class: ActivityNotification::Notification do
    association :target, factory: :confirmed_user
    association :notifiable, factory: :article
    key { "default.default" }
  end
end
