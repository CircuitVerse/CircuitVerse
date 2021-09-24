require 'controllers/notifications_controller_shared_examples'

describe ActivityNotification::NotificationsWithDeviseController, type: :controller do
  include ActivityNotification::ControllerSpec::RequestUtility

  let(:test_user)            { create(:confirmed_user) }
  let(:unauthenticated_user) { create(:confirmed_user) }
  let(:test_target)          { create(:admin, user: test_user) }
  let(:target_type)          { :admins }
  let(:typed_target_param)   { :admin_id }
  let(:extra_params)         { { devise_type: :users } }
  let(:valid_session)        {}

  context "signed in with devise as authenticated user" do
    before do
      sign_in test_user
    end
  
    it_behaves_like :notifications_controller
  end

  context "signed in with devise as unauthenticated user" do
    let(:target_params) { { target_type: target_type, devise_type: :users } }

    describe "GET #index" do
      before do
        sign_in unauthenticated_user
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
      end
  
      it "returns 403 as http status code" do
        expect(response.status).to eq(403)
      end
    end
  end

  context "unsigned in with devise" do
    let(:target_params) { { target_type: target_type, devise_type: :users } }

    describe "GET #index" do
      before do
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
      end
  
      it "returns 302 as http status code" do
        expect(response.status).to eq(302)
      end

      it "redirects to sign_in path" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context "without devise_type parameter" do
    let(:target_params) { { target_type: target_type } }

    describe "GET #index" do
      before do
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
      end
  
      it "returns 400 as http status code" do
        expect(response.status).to eq(400)
      end
    end
  end

  context "with wrong devise_type parameter" do
    let(:target_params) { { target_type: target_type, devise_type: :dummy_targets } }

    describe "GET #index" do
      before do
        get_with_compatibility :index, target_params.merge({ typed_target_param => test_target }), valid_session
      end
  
      it "returns 403 as http status code" do
        expect(response.status).to eq(403)
      end
    end
  end

  context "without target_id and (typed_target)_id parameters for devise integrated controller with devise_type option" do
    let(:target_params) { { target_type: target_type, devise_type: :users } }

    describe "GET #index" do
      before do
        sign_in test_target.user
        get_with_compatibility :index, target_params, valid_session
      end

      it "returns 200 as http status code" do
        expect(response.status).to eq(200)
      end
    end
  end
end
