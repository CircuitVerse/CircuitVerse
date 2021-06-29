# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Ltis", type: :request do
  before do
    @oauth_consumer_key_fromlms = "someKey"
  end

  describe "#launch" do
    context "lti content can not be accessed" do
        it "shows error if assignment is not present in db" do
            get '/lti/launch', params: {oauth_consumer_key: @oauth_consumer_key_fromlms}
            expect(response.status).to eq(401)
        end
        
        it "shows error if lti request is not proper" do
            get '/lti/launch'
            expect(response.status).to eq(401)
        end
    end
  end
end
