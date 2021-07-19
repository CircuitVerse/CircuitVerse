# frozen_string_literal: true

require "rails_helper"
require 'json'


describe LtiController, type: :request do
    before do
        @launch_url = 'http://localhost:3000/lti/launch'
        # shared keys for lms access
        @oauth_consumer_key_fromlms = "some_key"
        @oauth_shared_secret_fromlms = "some_secret"

        @mentor = FactoryBot.create(:user)
        @group = FactoryBot.create(:group, mentor: @mentor)
        @assignment = FactoryBot.create(:assignment, group: @group, lti_consumer_key: @oauth_consumer_key_fromlms, lti_shared_secret: @oauth_shared_secret_fromlms)
        @member = FactoryBot.create(:user)
        FactoryBot.create(:group_member, user: @member, group: @group)
    end

    let(:user_id) { "1" }
    let(:parameters) {
        {
            'launch_url' => @launch_url,
            'user_id' => user_id,
            'launch_presentation_return_url' => "http://circuitverse.org",
            'lti_version' => 'LTI-1p0',
            'lti_message_type' => 'basic-lti-launch-request',
            'resource_link_id' => '88391-e1919-bb3456',
            'lis_person_contact_email_primary' => @member.email,
            'tool_consumer_info_product_family_code' => 'moodle',
            'context_title' => 'sample Course'
        } 
    }

    describe "POST launch" do
        context "when assignment is present" do
            it "when lti parameters are ok and group member is present" do
                consumer = consumer = IMS::LTI::ToolConsumer.new(@oauth_consumer_key_fromlms, @oauth_shared_secret_fromlms, parameters)
                allow(consumer).to receive(:to_params).and_return(parameters)
                data = consumer.generate_launch_data
                # print data
                print data
                post "/lti/launch", params: {
                    oauth_consumer_key: @oauth_consumer_key_fromlms,
                    oauth_signature_method: 'HMAC-SHA1',
                    oauth_timestamp: data['oauth_timestamp'],
                    oauth_nonce: data['oauth_nonce'],
                    oauth_version: '1.0',
                    oauth_signature: data['oauth_signature'],
                    user_id: user_id,
                    launch_presentation_return_url: "http://circuitverse.org",
                    lti_version: 'LTI-1p0',
                    lti_message_type: 'basic-lti-launch-request',
                    resource_link_id: '88391-e1919-bb3456',
                    lis_person_contact_email_primary: @member.email,
                    tool_consumer_info_product_family_code: 'moodle',
                    context_title: 'sample Course',
                    launch_url: @launch_url
                }
                # expect 200 code
                expect(response.status).to eq(200)
            end
        end
    end
end