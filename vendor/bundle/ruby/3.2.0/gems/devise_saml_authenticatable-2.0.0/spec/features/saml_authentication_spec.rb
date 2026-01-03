require 'spec_helper'
require 'net/http'
require 'timeout'
require 'uri'
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--allow-insecure-localhost')
  options.add_argument('--ignore-certificate-errors')
  # Headless Chrome 134 is failing randomly - optimizing here to try and avoid it
  options.add_argument('--disable-background-timer-throttling')
  options.add_argument('--disable-backgrounding-occluded-windows')
  options.add_argument('--disable-renderer-backgrounding')
  options.add_argument('--no-sandbox')
  options.add_argument('--password-store=basic');
  options.add_argument('--suppress-message-center-popups');

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options,
  )
end
Capybara.default_driver = :chrome
Capybara.server = :webrick

describe "SAML Authentication", type: :feature do
  let(:idp_port) { 8009 }
  let(:sp_port)  { 8020 }

  shared_examples_for "it authenticates and creates users" do
    it "authenticates an existing user on a SP via an IdP" do
      create_user("you@example.com")

      visit 'http://localhost:8020/'
      expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))
      fill_in "Email", with: "you@example.com"
      fill_in "Password", with: "asdf"
      click_on "Sign in"
      expect(page).to have_content("you@example.com")
      expect(current_url).to eq("http://localhost:8020/")
    end

    it "creates a user on the SP from the IdP attributes" do
      visit 'http://localhost:8020/'
      expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))
      fill_in "Email", with: "you@example.com"
      fill_in "Password", with: "asdf"
      click_on "Sign in"
      expect(page).to have_content("you@example.com")
      expect(page).to have_content("A User")
      expect(current_url).to eq("http://localhost:8020/")
    end

    it "updates a user on the SP from the IdP attributes" do
      create_user("you@example.com")

      visit 'http://localhost:8020/'
      expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))
      fill_in "Email", with: "you@example.com"
      fill_in "Password", with: "asdf"
      click_on "Sign in"
      expect(page).to have_content("you@example.com")
      expect(page).to have_content("A User")
      expect(current_url).to eq("http://localhost:8020/")
    end

    it "logs a user out of the IdP via the SP" do
      sign_in

      # prove user is still signed in
      visit 'http://localhost:8020/'
      expect(page).to have_content("you@example.com")
      expect(current_url).to eq("http://localhost:8020/")

      click_on "Log out"
      # confirm the logout response redirected to the SP which in turn attempted to sign the user back in
      expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))

      # prove user is now signed out
      visit 'http://localhost:8020/'
      expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))
    end
  end

  shared_examples_for "it logs a user out via the IdP" do
    it 'logs a user out of the SP via the IdP' do
      sign_in

      visit "http://localhost:#{idp_port}/saml/sp_sign_out"

      visit 'http://localhost:8020/'
      expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))
    end
  end

  context "when the attributes are used to authenticate" do
    before(:each) do
      create_app('idp', 'INCLUDE_SUBJECT_IN_ATTRIBUTES' => "true")
      create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "false")
      @idp_pid = start_app('idp', idp_port)
      @sp_pid  = start_app('sp',  sp_port)
    end
    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it_behaves_like "it authenticates and creates users"
  end

  context "when the subject is used to authenticate" do
    before(:each) do
      create_app('idp', 'INCLUDE_SUBJECT_IN_ATTRIBUTES' => "false")
      create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "true")
      @idp_pid = start_app('idp', idp_port)
      @sp_pid  = start_app('sp',  sp_port)
    end
    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it_behaves_like "it authenticates and creates users"
  end

  context "when the session index key is set" do
    before(:each) do
      create_app('idp', 'INCLUDE_SUBJECT_IN_ATTRIBUTES' => "false")
      create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "true", 'SAML_SESSION_INDEX_KEY' => ":session_index")
      @idp_pid = start_app('idp', idp_port)
      @sp_pid  = start_app('sp',  sp_port)
    end
    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it_behaves_like "it authenticates and creates users"
    it_behaves_like "it logs a user out via the IdP"
  end

  context "when the session index key is not set" do
    before(:each) do
      create_app('idp', 'INCLUDE_SUBJECT_IN_ATTRIBUTES' => "false")
      create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "true", 'SAML_SESSION_INDEX_KEY' => "nil")
      @idp_pid = start_app('idp', idp_port)
      @sp_pid  = start_app('sp',  sp_port)
    end
    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it_behaves_like "it authenticates and creates users"
  end

  context "when the idp_settings_adapter key is set" do
    before(:each) do
      create_app('idp', 'INCLUDE_SUBJECT_IN_ATTRIBUTES' => "false")
      create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "true", 'IDP_SETTINGS_ADAPTER' => '"IdpSettingsAdapter"', 'IDP_ENTITY_ID_READER' => '"OurEntityIdReader"')

      # use a different port for this entity ID; configured in spec/support/idp_settings_adapter.rb.erb
      @idp_pid = start_app('idp', 8010)
      @sp_pid  = start_app('sp',  sp_port)
    end

    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it "authenticates an existing user on a SP via an IdP" do
      create_user("you@example.com")

      visit 'http://localhost:8020/users/saml/sign_in/?entity_id=http%3A%2F%2Flocalhost%3A8020%2Fsaml%2Fmetadata'
      expect(current_url).to match(%r(\Ahttp://localhost:8010/saml/auth\?SAMLRequest=))
    end
  end

  context "when the saml_failed_callback is set" do
    let(:valid_destination) { "true" }
    before(:each) do
      create_app('idp', 'INCLUDE_SUBJECT_IN_ATTRIBUTES' => "false", 'VALID_DESTINATION' => valid_destination)
      create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "true", 'SAML_FAILED_CALLBACK' => '"OurSamlFailedCallbackHandler"')

      @idp_pid = start_app('idp', idp_port)
      @sp_pid  = start_app('sp',  sp_port)
    end

    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it_behaves_like "it authenticates and creates users"

    context "a bad SAML Request" do
      let(:valid_destination) { "false" }
      it "redirects to the callback handler's redirect destination" do
        create_user("you@example.com")

        visit 'http://localhost:8020/'
        expect(current_url).to match(%r(\Ahttp://localhost:8009/saml/auth\?SAMLRequest=))
        fill_in "Email", with: "you@example.com"
        fill_in "Password", with: "asdf"
        click_on "Sign in"
        expect(page).to have_content(:all, "Example Domain This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.")
        expect(current_url).to eq("https://www.example.com/")
      end
    end
  end

  context "when the saml_attribute_map is set" do
    before(:each) do
      create_app(
        "idp",
        "EMAIL_ADDRESS_ATTRIBUTE_KEY" => "myemailaddress",
        "NAME_ATTRIBUTE_KEY" => "myname",
        "INCLUDE_SUBJECT_IN_ATTRIBUTES" => "false",
      )
      create_app(
        "sp",
        "ATTRIBUTE_MAP_RESOLVER" => '"AttributeMapResolver"',
        "USE_SUBJECT_TO_AUTHENTICATE" => "true",
      )
      @idp_pid = start_app("idp", idp_port)
      @sp_pid  = start_app("sp", sp_port)
    end
    after(:each) do
      stop_app("idp", @idp_pid)
      stop_app("sp", @sp_pid)
    end

    it_behaves_like "it authenticates and creates users"
  end

  def create_user(email)
    response = Net::HTTP.post_form(URI('http://localhost:8020/users'), email: email)
    expect(response.code).to eq('201')
  end

  def sign_in(entity_id: "")
    visit "http://localhost:8020/users/saml/sign_in/?entity_id=#{URI.encode_www_form_component(entity_id)}"
    fill_in "Email", with: "you@example.com"
    fill_in "Password", with: "asdf"
    click_on "Sign in"
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        sleep 0.1
        break if current_url == "http://localhost:8020/"
      end
    end
  rescue Timeout::Error
    expect(current_url).to eq("http://localhost:8020/")
  end
end
