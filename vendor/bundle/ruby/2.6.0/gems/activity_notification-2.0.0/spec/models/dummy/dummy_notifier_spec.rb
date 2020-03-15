# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/models/notifier_spec.rb').to_s
# require Rails.root.join('../../spec/concerns/common_spec.rb').to_s

describe Dummy::DummyNotifier, type: :model do

  it_behaves_like :notifier
  it_behaves_like :common

end
