unless ENV['AN_TEST_DB'] == 'mongodb'
  class Dummy::DummyBase < ActiveRecord::Base
  end
else
  class Dummy::DummyBase
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification
    include ActivityNotification::Models
  end
end