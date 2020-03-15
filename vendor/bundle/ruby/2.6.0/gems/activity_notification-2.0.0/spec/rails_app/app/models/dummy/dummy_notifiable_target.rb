unless ENV['AN_TEST_DB'] == 'mongodb'
  class Dummy::DummyNotifiableTarget < ActiveRecord::Base
    self.table_name = :users
    acts_as_target
    acts_as_notifiable :dummy_notifiable_targets, targets: -> (n, key) { Dummy::DummyNotifiableTarget.all }, tracked: true
  end
else
  class Dummy::DummyNotifiableTarget
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification
    field :email, type: String, default: ""
    field :name,  type: String

    include ActivityNotification::Models
    acts_as_target
    acts_as_notifiable :dummy_notifiable_targets, targets: -> (n, key) { Dummy::DummyNotifiableTarget.all }, tracked: true
  end
end
