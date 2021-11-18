require 'controllers/subscriptions_api_controller_shared_examples'

context "ActivityNotification::NotificationsApiWithDeviseController" do
  context "test admins API with associated users authentication" do

    describe "/api/v#{ActivityNotification::GEM_VERSION::MAJOR}", type: :request do
      include ActivityNotification::ControllerSpec::CommitteeUtility

      let(:root_path)            { "/api/v#{ActivityNotification::GEM_VERSION::MAJOR}" }
      let(:test_user)            { create(:confirmed_user) }
      let(:unauthenticated_user) { create(:confirmed_user) }
      let(:test_target)          { create(:admin, user: test_user) }
      let(:target_type)          { :admins }

      def sign_in_with_devise_token_auth(auth_user, status)
        post_with_compatibility "#{root_path}/auth/sign_in", params: { email: auth_user.email, password: "password" }
        expect(response).to have_http_status(status)
        @headers = response.header.slice("access-token", "client", "uid")
      end

      context "signed in with devise as authenticated user" do
        before do
          sign_in_with_devise_token_auth(test_user, 200)
        end
      
        it_behaves_like :subscriptions_api_request
      end

      context "signed in with devise as unauthenticated user" do
        let(:target_params) { { target_type: target_type, devise_type: :users } }

        describe "GET #index" do
          before do
            sign_in_with_devise_token_auth(unauthenticated_user, 200)
            get_with_compatibility "#{api_path}/subscriptions", headers: @headers
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
            get_with_compatibility "#{api_path}/subscriptions", headers: @headers
          end
      
          it "returns 401 as http status code" do
            expect(response.status).to eq(401)
          end
        end
      end
    end

  end
end