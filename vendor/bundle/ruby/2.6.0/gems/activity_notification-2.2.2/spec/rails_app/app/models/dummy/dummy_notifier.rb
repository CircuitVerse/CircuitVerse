unless ENV['AN_TEST_DB'] == 'mongodb'
  class Dummy::DummyNotifier < ActiveRecord::Base
    self.table_name = :users
    include ActivityNotification::Notifier
  end
else
  class Dummy::DummyNotifier
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification
    include ActivityNotification::Models
    include ActivityNotification::Notifier
    field :name,  type: String
  end
end
