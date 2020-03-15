require 'rails_helper'

module Commontator
  RSpec.describe CommontableConfig, type: :lib do
    it 'must respond to commontable attributes' do
      config = CommontableConfig.new
      COMMONTABLE_ATTRIBUTES.each do |attribute|
        expect(config).to respond_to(attribute)
      end
    end

    it "won't respond to engine or commontator attributes" do
      config = CommontableConfig.new
      (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES).each do |attribute|
        expect(config).not_to respond_to(attribute)
      end
    end

    it 'must be configurable' do
      proc = ->(thread) { 'Some name' }
      proc2 = ->(thread) { 'Another name' }
      config = CommontableConfig.new(commontable_name_proc: proc)
      expect(config.commontable_name_proc).to eq proc
      config = CommontableConfig.new(commontable_name_proc: proc2)
      expect(config.commontable_name_proc).to eq proc2
    end
  end
end
