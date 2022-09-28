# frozen_string_literal: true

require 'spec_helper'

describe Coveralls do
  before do
    allow(SimpleCov).to receive(:start)
    stub_api_post
    described_class.testing = true
  end

  describe '#will_run?' do
    it 'checks CI environemnt variables' do
      expect(described_class).to be_will_run
    end

    context 'with CI disabled' do
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('COVERALLS_RUN_LOCALLY').and_return(nil)
        allow(ENV).to receive(:[]).with('CI').and_return(nil)
        described_class.testing = false
      end

      it 'indicates no run' do
        expect(described_class).not_to be_will_run
      end
    end
  end

  describe '#should_run?' do
    it 'outputs to stdout when running locally' do
      described_class.testing = false
      described_class.run_locally = true
      silence do
        described_class.should_run?
      end
    end
  end

  describe '#wear!' do
    it 'receives block' do
      silence do
        described_class.wear! do
          add_filter 's'
        end
      end

      expect(::SimpleCov).to have_received(:start)
    end

    it 'uses string' do
      silence do
        described_class.wear! 'test_frameworks'
      end

      expect(::SimpleCov).to have_received(:start).with 'test_frameworks'
    end

    it 'uses default' do
      silence do
        described_class.wear!
      end

      expect(::SimpleCov).to have_received(:start).with no_args
      expect(::SimpleCov.filters.map(&:filter_argument)).to include 'vendor'
    end
  end

  describe '#wear_merged!' do
    it 'sets formatter to NilFormatter' do
      silence do
        described_class.wear_merged! 'rails' do
          add_filter '/spec/'
        end
      end

      expect(::SimpleCov.formatter).to be Coveralls::NilFormatter
    end
  end

  describe '#push!' do
    let(:coverage_hash) do
      { 'file.rb'=>{ 'lines'=>[nil] } }
    end

    before do
      allow(SimpleCov::ResultMerger).to receive(:merge_valid_results).and_return([['RSpec'], coverage_hash])
    end

    it 'sends existing test results' do
      result = false
      silence do
        result = described_class.push!
      end
      expect(result).to be_truthy
    end
  end

  describe '#setup!' do
    it 'sets SimpleCov adapter' do
      # rubocop:disable Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
      SimpleCovTmp = SimpleCov
      Object.send :remove_const, :SimpleCov
      silence { described_class.setup! }
      SimpleCov = SimpleCovTmp
      # rubocop:enable Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
    end
  end
end
