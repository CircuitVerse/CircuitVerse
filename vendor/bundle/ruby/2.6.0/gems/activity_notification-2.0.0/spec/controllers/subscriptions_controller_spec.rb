require 'controllers/subscriptions_controller_shared_examples'

describe ActivityNotification::SubscriptionsController, type: :controller do
  let(:test_target)        { create(:user) }
  let(:target_type)        { :users }
  let(:typed_target_param) { :user_id }
  let(:extra_params)       { {} }
  let(:valid_session)      {}

  it_behaves_like :subscription_controller

end
