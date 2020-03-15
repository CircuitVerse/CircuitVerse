require 'rails_helper'

module Commontator
  RSpec.describe ActsAsCommontable, type: :lib do
    it 'must add methods to ActiveRecord and subclasses' do
      expect(ActiveRecord::Base).to respond_to(:acts_as_commontable)
      expect(ActiveRecord::Base).to respond_to(:is_commontable)
      expect(ActiveRecord::Base.is_commontable).to eq false
      expect(DummyModel).to respond_to(:acts_as_commontable)
      expect(DummyModel).to respond_to(:is_commontable)
      expect(DummyModel.is_commontable).to eq true
      expect(DummyUser).to respond_to(:acts_as_commontable)
      expect(DummyUser).to respond_to(:is_commontable)
      expect(DummyUser.is_commontable).to eq false
    end

    it 'must modify models that act_as_commontable' do
      dummy = DummyModel.create
      expect(dummy).to respond_to(:thread)
      expect(dummy).to respond_to(:commontable_config)
      expect(dummy.commontable_config).to be_a(CommontableConfig)
    end
  end
end

