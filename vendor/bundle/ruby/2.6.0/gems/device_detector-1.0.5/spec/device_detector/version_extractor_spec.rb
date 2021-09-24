require_relative '../spec_helper'

describe DeviceDetector::VersionExtractor do

  subject { DeviceDetector::VersionExtractor.new(user_agent, regex_meta) }

  alias :extractor :subject

  describe '#call' do

    describe 'extractor without version' do

      let(:user_agent) { 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; Avant Browser; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)' }

      let(:regex_meta) do
        {
          :regex => 'Avant Browser',
          :name => 'Avant Browser',
          :version => ''
        }
      end

      it 'returns nil' do
        value(extractor.call).must_equal ''
      end

    end

    describe 'regex with dynamic matching' do

      let(:user_agent) { 'Mozilla/5.0 (X11; U; Linux i686; nl; rv:1.8.1b2) Gecko/20060821 BonEcho/2.0b2 (Debian-1.99+2.0b2+dfsg-1)' }
      let(:version) { 'BonEcho (2.0)' }
      let(:regex_meta) do
        {
          :regex => '(BonEcho|GranParadiso|Lorentz|Minefield|Namoroka|Shiretoko)/(\d+[\.\d]+)',
          :name => 'Firefox',
          :version => '$1 ($2)'
        }
      end

      it 'returns the correct version' do
        value(extractor.call).must_equal version
      end

      it 'removes trailing white spaces' do
        regex_meta[:version] = regex_meta[:version] + '   '
        value(extractor.call).must_equal version
      end

    end

    describe 'extractor with fixed version' do

      let(:user_agent) { 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)' }
      let(:regex_meta) do
        {
          :regex => 'MSIE.*Trident/4.0',
          :version => '8.0'
        }
      end

      it 'returns the correct version' do
        value(extractor.call).must_equal '8.0'
      end

    end

    describe 'unknown user agent' do

      let(:user_agent) { 'garbage' }
      let(:regex_meta) { {} }

      it 'returns nil' do
        value(extractor.call).must_be_nil
      end

    end
  end
end
