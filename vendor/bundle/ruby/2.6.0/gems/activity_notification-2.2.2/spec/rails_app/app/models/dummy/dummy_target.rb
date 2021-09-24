unless ENV['AN_TEST_DB'] == 'mongodb'
  class Dummy::DummyTarget < ActiveRecord::Base
    self.table_name = :users
    include ActivityNotification::Target
  end
else
  class Dummy::DummyTarget
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification
    include ActivityNotification::Models
    include ActivityNotification::Target
    field :email, type: String, default: ""
    field :name,  type: String
  end
end
