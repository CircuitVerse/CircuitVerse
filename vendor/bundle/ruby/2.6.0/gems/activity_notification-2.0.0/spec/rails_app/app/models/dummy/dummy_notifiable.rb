unless ENV['AN_TEST_DB'] == 'mongodb'
  class Dummy::DummyNotifiable < ActiveRecord::Base
    self.table_name = :articles
    include ActivityNotification::Notifiable
  end
else
  class Dummy::DummyNotifiable
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification
    include ActivityNotification::Models
    include ActivityNotification::Notifiable
    field :title, type: String
  end
end
