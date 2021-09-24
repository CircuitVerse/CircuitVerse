# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/models/target_spec.rb').to_s
# require Rails.root.join('../../spec/concerns/common_spec.rb').to_s

describe Dummy::DummyTarget, type: :model do

  it_behaves_like :target
  it_behaves_like :common

end
