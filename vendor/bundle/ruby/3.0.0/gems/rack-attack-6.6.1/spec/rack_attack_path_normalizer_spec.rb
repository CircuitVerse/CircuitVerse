# frozen_string_literal: true

require_relative 'spec_helper'

describe Rack::Attack::PathNormalizer do
  subject { Rack::Attack::PathNormalizer }

  it 'should have a normalize_path method' do
    _(subject.normalize_path('/foo')).must_equal '/foo'
  end

  describe 'FallbackNormalizer' do
    subject { Rack::Attack::FallbackPathNormalizer }

    it '#normalize_path does not change the path' do
      _(subject.normalize_path('')).must_equal ''
    end
  end
end
