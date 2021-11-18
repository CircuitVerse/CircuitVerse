require 'controllers/subscriptions_api_controller_shared_examples'

describe ActivityNotification::SubscriptionsApiController, type: :controller do
  let(:test_target)        { create(:user) }
  let(:target_type)        { :users }
  let(:typed_target_param) { :user_id }
  let(:extra_params)       { {} }
  let(:valid_session)      {}

  it_behaves_like :subscriptions_api_controller

  describe "/api/v#{ActivityNotification::GEM_VERSION::MAJOR}", type: :request do
    let(:root_path)          { "/api/v#{ActivityNotification::GEM_VERSION::MAJOR}" }
    let(:test_target)        { create(:user) }
    let(:target_type)        { :users }

    it_behaves_like :subscriptions_api_request
  end
end