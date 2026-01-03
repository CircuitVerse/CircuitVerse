require 'rails_helper'
require 'support/ruby_saml_support'

describe Devise::Strategies::SamlAuthenticatable do
  include RubySamlSupport

  subject(:strategy) { described_class.new(env, :user) }
  let(:env) { {} }
  let(:errors) { ["Test1", "Test2"] }

  let(:response) { double(:response, issuers: [idp_entity_id], :settings= => nil, is_valid?: true, sessionindex: '123123123', errors: errors) }
  let(:idp_entity_id) { "https://test/saml/metadata/123123" }
  before do
    allow(OneLogin::RubySaml::Response).to receive(:new).and_return(response)
  end

  let(:mapping) { double(:mapping, to: user_class) }
  let(:user_class) { double(:user_class, authenticate_with_saml: user, skip_session_storage: []) }
  let(:user) { double(:user) }
  before do
    allow(strategy).to receive(:mapping).and_return(mapping)
    allow(user).to(receive(:after_saml_authentication)) if user
  end

  let(:params) { {} }
  let(:session) { {} }
  before do
    allow(strategy).to receive(:params).and_return(params)
    allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
  end

  context "with a login SAMLResponse parameter" do
    let(:params) { {SAMLResponse: "PHNhbWxwOlJlc3BvbnNlIHhtbG5zOnNhbWw9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24iIHhtbG5zOnNhbWxwPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6cHJvdG9jb2wiIElEPSIxMjMxMjMxMjMxMjMxMjMiIFZlcnNpb249IjIuMCIgSXNzdWVJbnN0YW50PSIyMDE1LTA2LTMwVDE0OjQyOjI3WiIgRGVzdGluYXRpb249IntyZWNpcGllbnR9Ij48c2FtbDpJc3N1ZXI+aHR0cHM6Ly90ZXN0L3NhbWwvbWV0YWRhdGEvMTIzMTIzPC9zYW1sOklzc3Vlcj48c2FtbHA6U3RhdHVzPjxzYW1scDpTdGF0dXNDb2RlIFZhbHVlPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6c3RhdHVzOlN1Y2Nlc3MiLz48L3NhbWxwOlN0YXR1cz48c2FtbDpBc3NlcnRpb24geG1sbnM6c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFzc2VydGlvbiIgeG1sbnM6eHM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hIiB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIiBWZXJzaW9uPSIyLjAiIElEPSIyMzQyNDMyMzQxMjQxMjM0MTI0MyIgSXNzdWVJbnN0YW50PSIyMDE1LTA2LTMwVDE0OjQyOjI3WiI+PHNhbWw6SXNzdWVyPmh0dHBzOi8vYXBwLm9uZWxvZ2luLmNvbS9zYW1sL21ldGFkYXRhLzQ1MzA2MTwvc2FtbDpJc3N1ZXI+PGRzOlNpZ25hdHVyZSB4bWxuczpkcz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnIyI+PGRzOlNpZ25lZEluZm8+PGRzOkNhbm9uaWNhbGl6YXRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiLz48ZHM6U2lnbmF0dXJlTWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI3JzYS1zaGExIi8+PGRzOlJlZmVyZW5jZSBVUkk9IiNwZnhlOWJkZTYzNS01OWFhLTZjNTEtMWEzMS1mMzAyZjgzNGQ0ZDciPjxkczpUcmFuc2Zvcm1zPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjZW52ZWxvcGVkLXNpZ25hdHVyZSIvPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiLz48L2RzOlRyYW5zZm9ybXM+PGRzOkRpZ2VzdE1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNzaGExIi8+PGRzOkRpZ2VzdFZhbHVlPjZhMkxraGMyYjN6elFaQlIwYkFoQ0hrZkt1az08L2RzOkRpZ2VzdFZhbHVlPjwvZHM6UmVmZXJlbmNlPjwvZHM6U2lnbmVkSW5mbz48ZHM6U2lnbmF0dXJlVmFsdWU+Zk1qdThCYnpqaWV2OXBpbXlvM0lpVkNEU2R4dkNMMEhHQmZ4bGxVMmJ6WHVMMXRZcnZ5bkxFcVVSVUptL3k1SlZPRWVwbjdkbVhnanNnTVVUSkl0WTg0dTJlbUU0eXRGaFN6L203UFE5MitvTkN6RFpxMy9waGQ2UlR3RC9RSEJQdzFYV0ltMUxlOE42NldSZlZwNTc5YmZQc2pXMmhWSm1kUXU1cmVRTzVpTlVad0ZwNTFVUFBiZkhNUis1QnhPWkVsL0p6TkJOWk5jQzRkT0ErMDM1SkJ6WmlBb2liK1phUWJwdDVTMWxkQjZpanoyTGJJdGFHQ2E0MzVOc1p6MkQwakxsRmU0T0hYajJqcFdOa05leTZ4SEtBZ1o0a0FDbkVIQ08yN0t1dXdac3pLSFpqOFpTRUdhRWNIVld0eC9MbGRWK2NveUNNdUE4OXh6V0lOajJ3PT08L2RzOlNpZ25hdHVyZVZhbHVlPjxkczpLZXlJbmZvPjxkczpYNTA5RGF0YT48ZHM6WDUwOUNlcnRpZmljYXRlPk1JSUVNakNDQXhxZ0F3SUJBZ0lVY2NjNmczMU9RcnRaNHdJQkVUKzV2Z2c4Y0xNd0RRWUpLb1pJaHZjTkFRRUZCUUF3WVRFTE1Ba0dBMVVFQmhNQ1ZWTXhHakFZQmdOVkJBb01FVTl1WlNCTlpXUnBZMkZzSUVkeWIzVndNUlV3RXdZRFZRUUxEQXhQYm1WTWIyZHBiaUJKWkZBeEh6QWRCZ05WQkFNTUZrOXVaVXh2WjJsdUlFRmpZMjkxYm5RZ016Y3pPREV3SGhjTk1UUXdNVEl5TVRrek56UTJXaGNOTVRrd01USXpNVGt6TnpRMldqQmhNUXN3Q1FZRFZRUUdFd0pWVXpFYU1CZ0dBMVVFQ2d3UlQyNWxJRTFsWkdsallXd2dSM0p2ZFhBeEZUQVRCZ05WQkFzTURFOXVaVXh2WjJsdUlFbGtVREVmTUIwR0ExVUVBd3dXVDI1bFRHOW5hVzRnUVdOamIzVnVkQ0F6TnpNNE1UQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU5BUUJqZWdFTXo3MW1yZktWUkdXUlBObU1EeXdIZ010YjFlWWJoZ3YxRnNLd1hSTWVjdFdwQmtHc0FKb3dMU2hSWEtoYUg1Vm80VE5QYzFzTTNWK3dFcWlXYjRQcWRaMW1lZDJ3YXhSeUhOUnloR3NTN1ZvbUFpR041QWpCMU1IVFJQREJzY3J5d1N5RkZBNHVaQzZ0TkVrdWFYTjVTeElZTFNHUWJRNkF5RzJOQlpZWCttelVvRm9EOFRManVHSEVlUDFpdTJvWkpsVHBRZFhsL3VvakthRXFPWGo4ZjV6VlhQWUNhVm05ejg0WkgyWFFKY25Lc01pTzJTVllzQjlVaEdJV3NPRU9nYzFMOXN4bGkvR0xSSWRoc0poZW5QbWxsY2RBQ1BuN0hOU3hQM0tuSVRjcGJoc3hsN0pSVE1wSUd6ZzVoWTFLVTBrcXRtcGlnSzBIRUNBd0VBQWFPQjRUQ0IzakFNQmdOVkhSTUJBZjhFQWpBQU1CMEdBMVVkRGdRV0JCU2pnVlpON3lPRTZmV0E0anB5RHFQamtyOC9aakNCbmdZRFZSMGpCSUdXTUlHVGdCU2pnVlpON3lPRTZmV0E0anB5RHFQamtyOC9acUZscEdNd1lURUxNQWtHQTFVRUJoTUNWVk14R2pBWUJnTlZCQW9NRVU5dVpTQk5aV1JwWTJGc0lFZHliM1Z3TVJVd0V3WURWUVFMREF4UGJtVk1iMmRwYmlCSlpGQXhIekFkQmdOVkJBTU1Gazl1WlV4dloybHVJRUZqWTI5MWJuUWdNemN6T0RHQ0ZISEhPb045VGtLN1dlTUNBUkUvdWI0SVBIQ3pNQTRHQTFVZER3RUIvd1FFQXdJSGdEQU5CZ2txaGtpRzl3MEJBUVVGQUFPQ0FRRUFOWkhFTG03NnoreHBuOXlTUXdZNGZ4bVg2SnZEWDdXTUZQaVc2ZGgwcW13MzI1UW9TbkpWcDQ1a010TUs5UXpGaldaK2cwa0VmRnlocUh2RnUrSUs1NnpmVEpvRVIyNUpBblVCb01CNGJaS1lkbHQwYS9sSFVDZDJWYzM1dStWNHR5QmhOOTRPYTg0L2NnSnRRdFd0bVh4bVlrOVE3S25DN3lQTFhTelh2OW9wODg1OUM4akswbUFwQmlEcnpsSFA2QUt6SmxzWFVBQjUzbDdnOVBUYW55alNoWE9lOXZjVzBMU3FLakRnbHNtS2p4WG0vcFhHNUE2MXFqU1MwQytObnYzVmJOcDlCbFBnekpMc1lvZGNVaGROSkpjK0h5RS9BK2o5d2h0VjhENzdNWTlTTHR6YU5kdTZUMnNqdWVUQUNMNFR2bVdISGlMWnNqY3FnZHJMNGc9PTwvZHM6WDUwOUNlcnRpZmljYXRlPjwvZHM6WDUwOURhdGE+PC9kczpLZXlJbmZvPjwvZHM6U2lnbmF0dXJlPjxzYW1sOlN1YmplY3Q+PHNhbWw6TmFtZUlEIEZvcm1hdD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6MS4xOm5hbWVpZC1mb3JtYXQ6ZW1haWxBZGRyZXNzIj50ZXN0QHRlc3QuY29tPC9zYW1sOk5hbWVJRD48c2FtbDpTdWJqZWN0Q29uZmlybWF0aW9uIE1ldGhvZD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmNtOmJlYXJlciI+PHNhbWw6U3ViamVjdENvbmZpcm1hdGlvbkRhdGEgTm90T25PckFmdGVyPSIyMDE1LTA2LTMwVDE0OjQ1OjI3WiIgUmVjaXBpZW50PSJ7cmVjaXBpZW50fSIvPjwvc2FtbDpTdWJqZWN0Q29uZmlybWF0aW9uPjwvc2FtbDpTdWJqZWN0PjxzYW1sOkNvbmRpdGlvbnMgTm90QmVmb3JlPSIyMDE1LTA2LTMwVDE0OjM5OjI3WiIgTm90T25PckFmdGVyPSIyMDE1LTA2LTMwVDE0OjQ1OjI3WiI+PHNhbWw6QXVkaWVuY2VSZXN0cmljdGlvbj48c2FtbDpBdWRpZW5jZT57YXVkaWVuY2V9PC9zYW1sOkF1ZGllbmNlPjwvc2FtbDpBdWRpZW5jZVJlc3RyaWN0aW9uPjwvc2FtbDpDb25kaXRpb25zPjxzYW1sOkF1dGhuU3RhdGVtZW50IEF1dGhuSW5zdGFudD0iMjAxNS0wNi0zMFQxNDo0MjoyNloiIFNlc3Npb25Ob3RPbk9yQWZ0ZXI9IjIwMTUtMDctMDFUMTQ6NDI6MjdaIiBTZXNzaW9uSW5kZXg9Il8xZGEzNThkMC0wMTY0LTAxMzMtMGEwMy01NGFlNTI2NTZmNzgiPjxzYW1sOkF1dGhuQ29udGV4dD48c2FtbDpBdXRobkNvbnRleHRDbGFzc1JlZj51cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YWM6Y2xhc3NlczpQYXNzd29yZFByb3RlY3RlZFRyYW5zcG9ydDwvc2FtbDpBdXRobkNvbnRleHRDbGFzc1JlZj48L3NhbWw6QXV0aG5Db250ZXh0Pjwvc2FtbDpBdXRoblN0YXRlbWVudD48c2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQ+PHNhbWw6QXR0cmlidXRlIE5hbWVGb3JtYXQ9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphdHRybmFtZS1mb3JtYXQ6YmFzaWMiIE5hbWU9IkVtYWlsIj48c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIiB4c2k6dHlwZT0ieHM6c3RyaW5nIj5tbGluZHNheUBvbmVtZWRpY2FsLmNvbTwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT48L3NhbWw6QXR0cmlidXRlPjwvc2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQ+PC9zYW1sOkFzc2VydGlvbj48L3NhbWxwOlJlc3BvbnNlPg0KDQo="} }

    it "is valid" do
      expect(strategy).to be_valid
    end

    it "authenticates with the response" do
      expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], anything)
      expect(user_class).to receive(:authenticate_with_saml).with(response, nil)

      expect(strategy).to receive(:success!).with(user)
      strategy.authenticate!
      expect(session).to eq(Devise.saml_session_index_key => response.sessionindex)
    end

    context "when saml_session_index_key is not configured" do
      before do
        Devise.saml_session_index_key = nil
      end

      it "authenticates with the response" do
        expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], anything)
        expect(user_class).to receive(:authenticate_with_saml).with(response, nil)

        expect(strategy).to receive(:success!).with(user)
        strategy.authenticate!
        expect(session).to eq({})
      end
    end

    context "and a RelayState parameter" do
      let(:params) { super().merge(RelayState: "foo") }
      it "authenticates with the response" do
        expect(user_class).to receive(:authenticate_with_saml).with(response, params[:RelayState])

        expect(strategy).to receive(:success!).with(user)
        strategy.authenticate!
      end
    end

    context "when saml config uses an idp_adapter" do
      let(:idp_providers_adapter) {
        Class.new {
          def self.settings(idp_entity_id, request)
            base = {
              assertion_consumer_service_url: "acs url",
              assertion_consumer_service_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
              name_identifier_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
              sp_entity_id: "sp_issuer",
              idp_entity_id: "https://www.example.com",
              authn_context: "",
              idp_cert: "idp_cert"
            }
            with_ruby_saml_1_12_or_greater(proc {
              base.merge!(
                idp_slo_service_url: "idp_slo_url",
                idp_sso_service_url: "http://idp_sso_url",
              )
            }, else_do: proc {
              base.merge!(
                idp_slo_target_url: "idp_slo_url",
                idp_sso_target_url: "http://idp_sso_url",
              )
            })
            base
          end
        }
      }

      before do
        Devise.idp_settings_adapter = idp_providers_adapter
        allow(idp_providers_adapter).to receive(:settings).and_return({})
      end

      it "is valid" do
        expect(strategy).to be_valid
      end

      it "authenticates with the response for the corresponding idp" do
        expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], anything)
        expect(idp_providers_adapter).to receive(:settings).with(idp_entity_id, anything)
        expect(user_class).to receive(:authenticate_with_saml).with(response, params[:RelayState])

        expect(strategy).to receive(:success!).with(user)
        strategy.authenticate!
        expect(session).to eq(Devise.saml_session_index_key => response.sessionindex)
      end
    end

    context "and the resource does not exist" do
      let(:user) { nil }

      it "fails to authenticate" do
        strategy.authenticate!
        expect(strategy).to be_halted
        expect(strategy.message).to be(:invalid)
        expect(strategy.result).to be(:failure)
      end

      it 'logs the error' do
        expect(DeviseSamlAuthenticatable::Logger).to receive(:send).with('Resource could not be found')
        strategy.authenticate!
      end
    end

    context "and the SAML response is not valid" do
      class CallbackHandler
        def handle(response, strategy)
        end
      end

      before do
        allow(response).to receive(:is_valid?).and_return(false)
        @saml_failed_login = Devise.saml_failed_callback
        Devise.saml_failed_callback = CallbackHandler
      end

      after do
        Devise.saml_failed_callback = @saml_failed_login
      end

      it 'logs the error' do
        expect(DeviseSamlAuthenticatable::Logger).to receive(:send).with('Auth errors: Test1, Test2')
        strategy.authenticate!
      end

      it "fails to authenticate" do
        expect(strategy).to receive(:fail!).with(:invalid)
        strategy.authenticate!
      end

      it "redirects" do
        expect_any_instance_of(CallbackHandler).to receive(:handle).with(response, strategy)
        strategy.authenticate!
      end
    end

    context "when allowed_clock_drift is configured" do
      before do
        allow(Devise).to receive(:allowed_clock_drift_in_seconds).and_return(30)
      end

      it "is valid with the configured clock drift" do
        expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], hash_including(allowed_clock_drift: 30))
        expect(strategy).to be_valid
      end

      it "authenticates with the configured clock drift" do
        expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], hash_including(allowed_clock_drift: 30))

        expect(strategy).to receive(:success!).with(user)
        strategy.authenticate!
      end
    end

    context "when saml_validate_in_response_to is opted-in to" do
      let(:transaction_id) { "abc123" }

      before do
        allow(Devise).to receive(:saml_validate_in_response_to).and_return(true)
      end

      context "when the session has a saml_transaction_id" do
        let(:session) { { saml_transaction_id: transaction_id }}

        it "is valid with the matches_request_id parameter" do
          expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], hash_including(matches_request_id: transaction_id))
          expect(strategy).to be_valid
        end

        it "authenticates with the matches_request_id parameter" do
          expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], hash_including(matches_request_id: transaction_id))

          expect(strategy).to receive(:success!).with(user)
          strategy.authenticate!
        end
      end

      context "when the session is missing a saml_transaction_id" do
        it "uses 'ID_MISSING' for matches_request_id so validation will fail" do
          expect(OneLogin::RubySaml::Response).to receive(:new).with(params[:SAMLResponse], hash_including(matches_request_id: "ID_MISSING"))
          strategy.authenticate!
        end
      end
    end
  end

  it "is not valid without a SAMLResponse parameter" do
    expect(strategy).not_to be_valid
  end

  it "is permanent" do
    expect(strategy).to be_store
  end

  context "when the user should not be stored in the session" do
    before do
      allow(user_class).to receive(:skip_session_storage).and_return([:saml_auth])
    end

    it "is not stored" do
      expect(strategy).not_to be_store
    end
  end
end
