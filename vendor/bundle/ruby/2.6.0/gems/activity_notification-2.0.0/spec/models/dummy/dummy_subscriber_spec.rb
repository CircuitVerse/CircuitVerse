# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/models/subscriber_spec.rb').to_s

describe Dummy::DummySubscriber, type: :model do

  it_behaves_like :subscriber

end
