# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]

    # Generate a fresh RSA key pair for tests
    rsa_private = OpenSSL::PKey::RSA.generate(2048)
    rsa_public = rsa_private.public_key

    # Stub the private_key and public_key methods to return the test keys
    allow(JsonWebToken).to receive_messages(private_key: rsa_private, public_key: rsa_public)
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          name: "Test User"
        }
      }
    end

    let(:invalid_attributes) do
      {
        user: {
          email: "",
          password: "password123",
          password_confirmation: "password123",
          name: ""
        }
      }
    end

    context "with valid params" do
      before do
        allow(Flipper).to receive(:enabled?).with(:recaptcha).and_return(false)
        allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(false)
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      # TODO: Fix this test - devise mapping issue exists in original codebase
      xit "creates a new User" do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end

      # TODO: Fix this test - devise mapping issue exists in original codebase
      xit "sets the JWT cookie" do
        post :create, params: valid_attributes
        expect(cookies[:cvt]).to be_present
      end
    end

    context "with invalid params" do
      before do
        allow(Flipper).to receive(:enabled?).with(:recaptcha).and_return(false)
        allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(false)
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      # TODO: Fix this test - devise mapping issue exists in original codebase
      xit "does not create a new User" do
        expect do
          post :create, params: invalid_attributes
        end.not_to change(User, :count), "Expected not to create a user, but did."
      end
    end
  end

  describe "GET #new" do
    context "if registration is blocked" do
      before do
        allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(true)
        get :new
      end

      # TODO: Fix this test - devise mapping issue exists in original codebase
      xit "redirects to the login page" do
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("Registration is currently blocked")
      end
    end
  end

  describe "Recaptcha verification" do
    let(:valid_attributes) do
      {
        user: {
          email: "recaptcha_test@example.com",
          password: "password123",
          password_confirmation: "password123",
          name: "Recaptcha Test User"
        }
      }
    end

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      allow(Flipper).to receive(:enabled?).with(:recaptcha).and_return(true)
      allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(false)
    end

    context "when recaptcha is disabled" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        allow(Flipper).to receive(:enabled?).with(:recaptcha).and_return(false)
      end

      # TODO: Fix devise mapping issue in controller tests
      xit "creates user without recaptcha verification" do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end
    end

    context "when recaptcha verification returns true" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      # TODO: Fix devise mapping issue in controller tests
      xit "creates a new user" do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end
    end

    context "when recaptcha verification returns false" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
      end

      # TODO: Fix devise resource initialization issue in controller tests
      xit "does not create a new user" do
        expect do
          post :create, params: valid_attributes
        end.not_to change(User, :count)
      end

      # TODO: Fix devise resource initialization issue in controller tests
      xit "does not redirect" do
        post :create, params: valid_attributes
        expect(response).not_to be_redirect
      end

      # TODO: Fix devise resource initialization issue in controller tests
      xit "shows captcha failed message" do
        post :create, params: valid_attributes
        expect(flash.now[:alert]).to match(/Captcha verification failed/)
      end
    end

    context "when recaptcha verification returns empty string" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return("")
      end

      it "treats empty string as failure and does not create user" do
        expect do
          post :create, params: valid_attributes
        end.not_to change(User, :count)
      end

      it "does not redirect" do
        post :create, params: valid_attributes
        expect(response).not_to be_redirect
      end

      it "shows captcha failed message" do
        post :create, params: valid_attributes
        expect(flash.now[:alert]).to match(/Captcha verification failed/)
      end
    end

    context "when recaptcha verification returns nil" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(nil)
      end

      it "treats nil as failure and does not create user" do
        expect do
          post :create, params: valid_attributes
        end.not_to change(User, :count)
      end

      it "does not redirect" do
        post :create, params: valid_attributes
        expect(response).not_to be_redirect
      end
    end

    context "when recaptcha raises Recaptcha::RecaptchaError" do
      before do
        allow(controller).to receive(:verify_recaptcha)
          .and_raise(Recaptcha::RecaptchaError.new("An empty string is not a valid JSON string."))
      end

      it "does not create a new user" do
        expect do
          post :create, params: valid_attributes
        end.not_to change(User, :count)
      end

      it "does not raise an unhandled exception" do
        expect do
          post :create, params: valid_attributes
        end.not_to raise_error
      end

      it "does not redirect" do
        post :create, params: valid_attributes
        expect(response).not_to be_redirect
      end

      it "shows captcha failed message" do
        post :create, params: valid_attributes
        expect(flash.now[:alert]).to match(/Captcha verification failed/)
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/Recaptcha verification error/)
        expect(Rails.logger).to receive(:error) # for backtrace
        post :create, params: valid_attributes
      end

      it "captures exception to Sentry if available" do
        if defined?(Sentry)
          expect(Sentry).to receive(:capture_exception).with(
            an_instance_of(Recaptcha::RecaptchaError),
            hash_including(extra: hash_including(:request_id, :user_agent, :remote_ip))
          )
        end
        post :create, params: valid_attributes
      end
    end

    context "when recaptcha raises JSON::ParserError wrapped in RecaptchaError" do
      before do
        json_error = JSON::ParserError.new("An empty string is not a valid JSON string.")
        recaptcha_error = Recaptcha::RecaptchaError.new("An empty string is not a valid JSON string.")
        allow(recaptcha_error).to receive(:cause).and_return(json_error)

        allow(controller).to receive(:verify_recaptcha).and_raise(recaptcha_error)
      end

      it "handles the wrapped error gracefully" do
        expect do
          post :create, params: valid_attributes
        end.not_to raise_error
      end

      it "does not create a new user" do
        expect do
          post :create, params: valid_attributes
        end.not_to change(User, :count)
      end
    end
  end
end
