# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/models/group_spec.rb').to_s
# require Rails.root.join('../../spec/concerns/common_spec.rb').to_s

describe Dummy::DummyGroup, type: :model do

  it_behaves_like :group
  it_behaves_like :common

end
