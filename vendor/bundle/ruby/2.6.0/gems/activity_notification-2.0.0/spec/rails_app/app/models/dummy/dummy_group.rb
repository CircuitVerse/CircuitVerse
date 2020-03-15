unless ENV['AN_TEST_DB'] == 'mongodb'
  class Dummy::DummyGroup < ActiveRecord::Base
    self.table_name = :articles
    include ActivityNotification::Group
  end
else
  class Dummy::DummyGroup
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification
    include ActivityNotification::Models
    include ActivityNotification::Group
    field :title, type: String
  end
end
