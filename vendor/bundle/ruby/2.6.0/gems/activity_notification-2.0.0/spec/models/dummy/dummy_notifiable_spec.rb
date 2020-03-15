# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/models/notifiable_spec.rb').to_s
# require Rails.root.join('../../spec/concerns/common_spec.rb').to_s

describe Dummy::DummyNotifiable, type: :model do

  it_behaves_like :notifiable
  it_behaves_like :common

end
