require "fileutils"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.before :each do
    @original_saml_config = Devise.saml_config
    @original_sign_out_success_url = Devise.saml_sign_out_success_url
    @original_saml_session_index_key = Devise.saml_session_index_key
  end

  config.after :each do
    Devise.saml_config = @original_saml_config
    Devise.saml_sign_out_success_url = @original_sign_out_success_url
    Devise.saml_session_index_key = @original_saml_session_index_key
    Devise.idp_settings_adapter = nil
  end

  config.after :suite do
    FileUtils.rm_rf($working_directory) if $working_directory
  end
end

require 'support/rails_app'

require "action_controller" # https://github.com/heartcombo/responders/pull/95
require 'devise_saml_authenticatable'
