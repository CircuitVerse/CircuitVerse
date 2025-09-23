require 'spec_helper'

describe Devise::Models::SamlAuthenticatable do
  class Model
    include Devise::Models::SamlAuthenticatable
    attr_accessor :email, :name, :saved
    def initialize(params = {})
      @email = params[:email]
      @name = params[:name]
      @new_record = params.fetch(:new_record, true)
    end

    def new_record?
      @new_record
    end

    def save!
      self.saved = true
    end

    # Fake out ActiveRecord and Devise API to satisfy verifiable mocks
    class << self
      def find_by(*args); end
      def logger; end
    end
  end

  before do
    logger = double(:logger).as_null_object
    allow(Model).to receive(:logger).and_return(logger)
    allow(Rails).to receive(:logger).and_return(logger)
  end

  before do
    allow(Devise).to receive(:saml_attribute_map_resolver).and_return(attribute_map_resolver)
    allow(Devise).to receive(:saml_default_user_key).and_return(:email)
    allow(Devise).to receive(:saml_create_user).and_return(false)
    allow(Devise).to receive(:saml_use_subject).and_return(false)
  end

  before do
    allow(Rails).to receive(:root).and_return("/railsroot")
  end

  let(:attribute_map_resolver) {
    Class.new(::DeviseSamlAuthenticatable::DefaultAttributeMapResolver) do
      def attribute_map
        {
          "saml-email-format" => "email",
          "saml-name-format" => "name",
        }
      end
    end
  }
  let(:attributemap) { attribute_map_resolver.new(nil).attribute_map }
  let(:response) { double(:response, attributes: attributes, name_id: name_id) }
  let(:attributes) {
    OneLogin::RubySaml::Attributes.new(
      'saml-email-format' => ['user@example.com'],
      'saml-name-format'  => ['A User'],
    )
  }
  let(:name_id) { nil }

  it "looks up the user by the configured default user key" do
    user = Model.new(new_record: false)
    expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
    expect(Model.authenticate_with_saml(response, nil)).to eq(user)
  end

  it "returns nil if it cannot find a user" do
    expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
    expect(Model.authenticate_with_saml(response, nil)).to be_nil
  end

  context "when configured to use the subject" do
    let(:attributes) { OneLogin::RubySaml::Attributes.new('saml-name-format' => ['A User']) }
    let(:name_id) { 'user@example.com' }

    before do
      allow(Devise).to receive(:saml_use_subject).and_return(true)
    end

    it "looks up the user by the configured default user key" do
      user = Model.new(new_record: false)
      expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
      expect(Model.authenticate_with_saml(response, nil)).to eq(user)
    end

    it "returns nil if it cannot find a user" do
      expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
      expect(Model.authenticate_with_saml(response, nil)).to be_nil
    end

    context "when configured to create a user and the user is not found" do
      before do
        allow(Devise).to receive(:saml_create_user).and_return(true)
      end

      it "creates and returns a new user with the name identifier and given attributes" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
        model = Model.authenticate_with_saml(response, nil)
        expect(model.email).to eq('user@example.com')
        expect(model.name).to  eq('A User')
        expect(model.saved).to be(true)
      end
    end

    context "when configured to create a user by a proc and the user is not found" do
      before do
        create_user_proc = -> (model_class, _saml_response, auth_value) { model_class == Model && auth_value == 'user@example.com' }
        allow(Devise).to receive(:saml_create_user).and_return(create_user_proc)
      end

      context "when the proc returns true" do
        it "creates and returns a new user with the name identifier and given attributes" do
          expect(Model).to receive(:find_by).with({ email: name_id }).and_return(nil)
          model = Model.authenticate_with_saml(response, nil)
          expect(model.email).to eq('user@example.com')
          expect(model.name).to  eq('A User')
          expect(model.saved).to be(true)
        end
      end

      context "when the proc returns false" do
        let(:name_id) { 'do_not_create@example.com' }

        it "does not creates new user" do
          expect(Model).to receive(:find_by).with({ email: name_id }).and_return(nil)
          expect(Model.authenticate_with_saml(response, nil)).to be_nil
        end
      end
    end

    context "when configured to update a user and the user is found" do
      before do
        allow(Devise).to receive(:saml_update_user).and_return(true)
      end

      it "creates and returns a new user with the name identifier and given attributes" do
        user = Model.new(email: "old_mail@mail.com", name: "old name", new_record: false)
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        model = Model.authenticate_with_saml(response, nil)
        expect(model.email).to eq('user@example.com')
        expect(model.name).to  eq('A User')
        expect(model.saved).to be(true)
      end
    end

    context "when configured to update a user by a proc and the user is found" do
      let(:user) { Model.new(email: 'old_mail@mail.com', name: 'old name', new_record: false) }

      before do
        update_user_proc = -> (model_class, _saml_response, auth_value) { model_class == Model && auth_value == 'user@example.com' }
        allow(Devise).to receive(:saml_update_user).and_return(update_user_proc)
      end

      context "when the proc returns true" do
        it "updates user with given attributes" do
          expect(Model).to receive(:find_by).with({ email: name_id }).and_return(user)
          model = Model.authenticate_with_saml(response, nil)
          expect(model.email).to eq('user@example.com')
          expect(model.name).to  eq('A User')
          expect(model.saved).to be(true)
        end
      end

      context "when the proc returns false" do
        let(:name_id) { 'do_not_update@example.com' }

        it "does not update user" do
          expect(Model).to receive(:find_by).with({ email: name_id }).and_return(user)
          model = Model.authenticate_with_saml(response, nil)
          expect(model.email).to eq('old_mail@mail.com')
          expect(model.name).to  eq('old name')
        end
      end
    end
  end


  context "when configured to create an user and the user is not found" do
    before do
      allow(Devise).to receive(:saml_create_user).and_return(true)
    end

    it "creates and returns a new user with the given attributes" do
      expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
      model = Model.authenticate_with_saml(response, nil)
      expect(model.email).to eq('user@example.com')
      expect(model.name).to  eq('A User')
      expect(model.saved).to be(true)
    end
  end

  context "when configured to create a user by a proc and the user is not found" do
    let(:create_user_proc) { -> (_model_class, saml_response, _auth_value) { saml_response.raw_response.issuers.first == 'to_create_idp' } }

    before do
      allow(Devise).to receive(:saml_create_user).and_return(create_user_proc)
    end

    context "when the proc returns true" do
      let(:response) { double(:response, issuers: ['to_create_idp'], attributes: attributes, name_id: name_id) }

      it "creates and returns a new user with the name identifier and given attributes" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
        model = Model.authenticate_with_saml(response, nil)
        expect(model.email).to eq('user@example.com')
        expect(model.name).to  eq('A User')
        expect(model.saved).to be(true)
      end
    end

    context "when the proc returns false" do
      let(:response) { double(:response, issuers: ['do_not_create_idp'], attributes: attributes, name_id: name_id) }

      it "does not creates new user" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
        expect(Model.authenticate_with_saml(response, nil)).to be_nil
      end
    end
  end

  context "when configured to update an user" do
    before do
      allow(Devise).to receive(:saml_update_user).and_return(true)
    end

    it "returns nil if the user is not found" do
      expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
      expect(Model.authenticate_with_saml(response, nil)).to be_nil
    end

    it "updates the attributes if the user is found" do
      user = Model.new(email: "old_mail@mail.com", name: "old name", new_record: false)
      expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
      model = Model.authenticate_with_saml(response, nil)
      expect(model.email).to eq('user@example.com')
      expect(model.name).to  eq('A User')
      expect(model.saved).to be(true)
    end
  end

  context "when configured to update a user by a proc and the user is found" do
    let(:user) { Model.new(email: 'old_mail@mail.com', name: 'old name', new_record: false) }
    let(:update_user_proc) { -> (_model_class, saml_response, _auth_value) { saml_response.raw_response.issuers.first == 'to_update_idp' } }

    before do
      allow(Devise).to receive(:saml_update_user).and_return(update_user_proc)
    end

    context "when the proc returns true" do
      let(:response) { double(:response, issuers: ['to_update_idp'], attributes: attributes, name_id: name_id) }

      it "updates user with given attributes" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        model = Model.authenticate_with_saml(response, nil)
        expect(model.email).to eq('user@example.com')
        expect(model.name).to  eq('A User')
        expect(model.saved).to be(true)
      end
    end

    context "when the proc returns false" do
      let(:response) { double(:response, issuers: ['do_not_update_idp'], attributes: attributes, name_id: name_id) }

      it "does not update user" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        model = Model.authenticate_with_saml(response, nil)
        expect(model.email).to eq('old_mail@mail.com')
        expect(model.name).to  eq('old name')
      end
    end
  end

  context "when configured with a case-insensitive key" do
    shared_examples "correct downcasing" do
      before do
        allow(Devise).to receive(:case_insensitive_keys).and_return([:email])
      end

      it "looks up the user with a downcased value" do
        user = Model.new(new_record: false)
        expect(Model).to receive(:find_by).with({ email: 'upper@example.com' }).and_return(user)
        expect(Model.authenticate_with_saml(response, nil)).to eq(user)
      end
    end

    context "when configured to use the subject" do
      let(:name_id) { 'UPPER@example.com' }

      before do
        allow(Devise).to receive(:saml_use_subject).and_return(true)
      end

      include_examples "correct downcasing"
    end

    context "when using default user key" do
      let(:attributes) { OneLogin::RubySaml::Attributes.new('saml-email-format' => ['UPPER@example.com']) }

      include_examples "correct downcasing"
    end
  end

  context "when configured with a resource validator class" do
    let(:validator_class) { double("validator") }
    let(:validator) { double("validator") }
    let(:user) { Model.new(new_record: false) }

    before do
      allow(Devise).to receive(:saml_resource_validator).and_return(validator_class)
      allow(validator_class).to receive(:new).and_return(validator)
    end

    context "and sent a valid value" do
      before do
        allow(validator).to receive(:validate).with(user, response).and_return(true)
      end

      it "returns the user" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        expect(Model.authenticate_with_saml(response, nil)).to eq(user)
      end
    end

    context "and sent an invalid value" do
      before do
        allow(validator).to receive(:validate).with(user, response).and_return(false)
      end

      it "returns nil" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        expect(Model.authenticate_with_saml(response, nil)).to be_nil
      end
    end
  end


  context "when configured with a resource validator hook" do
    let(:validator_hook) { double("validator_hook") }
    let(:decorated_response) { ::SamlAuthenticatable::SamlResponse.new(response, attributemap) }
    let(:user) { Model.new(new_record: false) }

    before do
      allow(Devise).to receive(:saml_resource_validator_hook).and_return(validator_hook)
      allow(::SamlAuthenticatable::SamlResponse).to receive(:new).with(response, attributemap).and_return(decorated_response)
    end

    context "and sent a valid value" do
      before do
        expect(validator_hook).to receive(:call).with(user, decorated_response, 'user@example.com').and_return(true)
      end

      it "returns the user" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        expect(Model.authenticate_with_saml(response, nil)).to eq(user)
      end
    end

    context "and sent an invalid value" do
      before do
        expect(validator_hook).to receive(:call).with(user, decorated_response, 'user@example.com').and_return(false)
      end

      it "returns nil" do
        expect(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(user)
        expect(Model.authenticate_with_saml(response, nil)).to be_nil
      end
    end
  end


  context "when configured to use a custom update hook" do
    it "can replicate the default behaviour in a custom hook" do
      configure_hook do |user, saml_response|
        Devise.saml_default_update_resource_hook.call(user, saml_response)
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user.name).to eq(attributes['saml-name-format'])
      expect(new_user.email).to eq(attributes['saml-email-format'])
    end

    it "can extend the default behaviour with custom transformations" do
      configure_hook do |user, saml_response|
        Devise.saml_default_update_resource_hook.call(user, saml_response)

        user.email = "ext+#{user.email}"
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user.name).to eq(attributes['saml-name-format'])
      expect(new_user.email).to eq("ext+#{attributes['saml-email-format']}")
    end

    it "can extend the default behaviour using information from the saml response" do
      configure_hook do |user, saml_response|
        Devise.saml_default_update_resource_hook.call(user, saml_response)

        name_id = saml_response.raw_response.name_id
        user.name += "@#{name_id}"
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user.name).to eq("#{attributes['saml-name-format']}@#{response.name_id}")
      expect(new_user.email).to eq(attributes['saml-email-format'])
    end

    def configure_hook(&block)
      allow(Model).to receive(:find_by).with({ email: 'user@example.com' }).and_return(nil)
      allow(Devise).to receive(:saml_default_user_key).and_return(:email)
      allow(Devise).to receive(:saml_create_user).and_return(true)
      allow(Devise).to receive(:saml_update_resource_hook).and_return(block)
    end
  end

  context "when configured to use a custom user locator" do
    let(:name_id) { 'SomeUsername' }

    it "can replicate the default behaviour for a new user in a custom locator" do
      allow(Model).to receive(:find_by).with({ email: attributes['saml-email-format'] }).and_return(nil)

      configure_hook do |model, saml_response, auth_value|
        Devise.saml_default_resource_locator.call(model, saml_response, auth_value)
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user.name).to eq(attributes['saml-name-format'])
      expect(new_user.email).to eq(attributes['saml-email-format'])
    end

    it "can replicate the default behaviour for an existing user in a custom locator" do
      user = Model.new(email: attributes['saml-email-format'], name: attributes['saml-name-format'])
      user.save!

      allow(Model).to receive(:find_by).with({ email: attributes['saml-email-format'] }).and_return(user)

      configure_hook do |model, saml_response, auth_value|
        Devise.saml_default_resource_locator.call(model, saml_response, auth_value)
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user).to eq(user)
      expect(new_user.name).to eq(attributes['saml-name-format'])
      expect(new_user.email).to eq(attributes['saml-email-format'])
    end

    it "can change the default behaviour for a new user from the saml response" do
      allow(Model).to receive(:find_by).with({ foo: attributes['saml-email-format'], bar: name_id }).and_return(nil)

      configure_hook do |model, saml_response, auth_value|
        name_id = saml_response.raw_response.name_id
        model.find_by(foo: auth_value, bar: name_id)
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user.name).to eq(attributes['saml-name-format'])
      expect(new_user.email).to eq(attributes['saml-email-format'])
    end

    it "can change the default behaviour for an existing user from the saml response" do
      user = Model.new(email: attributes['saml-email-format'], name: attributes['saml-name-format'])
      user.save!

      allow(Model).to receive(:find_by).with({ foo: attributes['saml-email-format'], bar: name_id }).and_return(user)

      configure_hook do |model, saml_response, auth_value|
        name_id = saml_response.raw_response.name_id
        model.find_by(foo: auth_value, bar: name_id)
      end

      new_user = Model.authenticate_with_saml(response, nil)

      expect(new_user).to eq(user)
      expect(new_user.name).to eq(attributes['saml-name-format'])
      expect(new_user.email).to eq(attributes['saml-email-format'])
    end

    def configure_hook(&block)
      allow(Devise).to receive(:saml_default_user_key).and_return(:email)
      allow(Devise).to receive(:saml_create_user).and_return(true)
      allow(Devise).to receive(:saml_resource_locator).and_return(block)
    end
  end

  describe "::attribute_map" do
    it "returns the attribute map" do
      expect(Model.attribute_map).to eq(attributemap)
    end
  end
end
