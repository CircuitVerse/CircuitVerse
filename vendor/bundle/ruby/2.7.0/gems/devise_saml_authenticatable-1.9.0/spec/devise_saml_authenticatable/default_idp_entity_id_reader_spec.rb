require "spec_helper"

describe DeviseSamlAuthenticatable::DefaultIdpEntityIdReader do
  describe ".entity_id" do
    context "when there is a SAMLRequest in the params" do
      let(:params) { {SAMLRequest: "logout request"} }
      let(:slo_logout_request) { double('slo_logout_request', issuer: 'meow')}
      before do
        allow(OneLogin::RubySaml::SloLogoutrequest).to receive(:new).and_return(slo_logout_request)
      end

      it "uses an OneLogin::RubySaml::SloLogoutrequest to get the idp_entity_id" do
        expect(OneLogin::RubySaml::SloLogoutrequest).to receive(:new).with("logout request", hash_including)
        expect(described_class.entity_id(params)).to eq("meow")
      end

      context "and allowed_clock_drift is configured" do
        before do
          allow(Devise).to receive(:allowed_clock_drift_in_seconds).and_return(30)
        end

        it "allows the configured clock drift" do
          expect(OneLogin::RubySaml::SloLogoutrequest).to receive(:new).with("logout request", hash_including(allowed_clock_drift: 30))
          expect(described_class.entity_id(params)).to eq("meow")
        end
      end
    end

    context "when there is a SAMLResponse in the params" do
      let(:params) { {SAMLResponse: "auth response"} }
      let(:response) { double('response', issuers: ['meow'] )}
      before do
        allow(OneLogin::RubySaml::Response).to receive(:new).and_return(response)
      end

      it "uses an OneLogin::RubySaml::Response to get the idp_entity_id" do
        expect(OneLogin::RubySaml::Response).to receive(:new).with("auth response", hash_including)
        expect(described_class.entity_id(params)).to eq("meow")
      end

      context "and allowed_clock_drift is configured" do
        before do
          allow(Devise).to receive(:allowed_clock_drift_in_seconds).and_return(30)
        end

        it "allows the configured clock drift" do
          expect(OneLogin::RubySaml::Response).to receive(:new).with("auth response", hash_including(allowed_clock_drift: 30))
          expect(described_class.entity_id(params)).to eq("meow")
        end
      end
    end
  end
end
