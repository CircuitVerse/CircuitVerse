# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]

    # Generate a fresh RSA key pair for tests
    rsa_private = OpenSSL::PKey::RSA.generate(2048)
    rsa_public = rsa_private.public_key

    # Stub the private_key and public_key methods to return the test keys
    allow(JsonWebToken).to receive(:private_key).and_return(rsa_private)
    allow(JsonWebToken).to receive(:public_key).and_return(rsa_public)
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
end
