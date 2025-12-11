# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]

    # Generate a fresh RSA key pair for tests
    rsa_private = OpenSSL::PKey::RSA.generate(2048)
    rsa_public = rsa_private.public_key

    # Stub the private_key and public_key methods to return the test keys
    allow(JsonWebToken).to receive_messages(private_key: rsa_private, public_key: rsa_public)
  end

  describe "POST #create" do
    let(:user) { FactoryBot.create(:user) }
    let(:valid_attributes) do
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end

    context "with valid params" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      it "logs in the user" do
        post :create, params: valid_attributes
        expect(subject.current_user).to eq(user)
      end

      it "sets the JWT cookie" do
        post :create, params: valid_attributes
        expect(cookies[:cvt]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in FactoryBot.create(:user)
      cookies[:cvt] = "test_token"
    end

    it "logs out the user" do
      delete :destroy
      expect(subject.current_user).to be_nil
    end

    it "removes the JWT cookie" do
      delete :destroy
      expect(response.cookies["cvt"]).to be_nil
    end
  end

  describe "Recaptcha verification" do
    let(:user) { FactoryBot.create(:user) }
    let(:valid_attributes) do
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end

    before do
      allow(Flipper).to receive(:enabled?).with(:recaptcha).and_return(true)
    end

    context "when recaptcha is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:recaptcha).and_return(false)
      end

      it "logs in user without recaptcha verification" do
        post :create, params: valid_attributes
        expect(subject.current_user).to eq(user)
      end
    end

    context "when recaptcha verification returns true" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      it "logs in the user" do
        post :create, params: valid_attributes
        expect(subject.current_user).to eq(user)
      end
    end

    context "when recaptcha verification returns false" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
      end

      it "does not log in the user" do
        post :create, params: valid_attributes
        expect(subject.current_user).to be_nil
      end

      it "renders the new template" do
        post :create, params: valid_attributes
        expect(response).to render_template(:new)
      end

      it "shows captcha failed message" do
        post :create, params: valid_attributes
        expect(flash.now[:alert]).to match(/Captcha verification failed/)
      end
    end

    context "when recaptcha verification returns empty string" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return("")
      end

      it "treats empty string as failure and does not log in user" do
        post :create, params: valid_attributes
        expect(subject.current_user).to be_nil
      end

      it "renders the new template" do
        post :create, params: valid_attributes
        expect(response).to render_template(:new)
      end
    end

    context "when recaptcha verification returns nil" do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(nil)
      end

      it "treats nil as failure and does not log in user" do
        post :create, params: valid_attributes
        expect(subject.current_user).to be_nil
      end
    end

    context "when recaptcha raises Recaptcha::RecaptchaError" do
      before do
        allow(controller).to receive(:verify_recaptcha)
          .and_raise(Recaptcha::RecaptchaError.new("An empty string is not a valid JSON string."))
      end

      it "does not log in the user" do
        post :create, params: valid_attributes
        expect(subject.current_user).to be_nil
      end

      it "does not raise an unhandled exception" do
        expect do
          post :create, params: valid_attributes
        end.not_to raise_error
      end

      it "renders the new template" do
        post :create, params: valid_attributes
        expect(response).to render_template(:new)
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
    end
  end
end
