require 'spec_helper'

describe OmniAuth::Strategies::GitLab do
  let(:access_token) { double('AccessToken') }
  let(:parsed_response) { double('ParsedResponse') }
  let(:response) { double('Response', parsed: parsed_response) }

  let(:enterprise_site) { 'https://some.other.site.com/api/v3' }

  let(:gitlab_service) { OmniAuth::Strategies::GitLab.new({}) }
  let(:enterprise) do
    OmniAuth::Strategies::GitLab.new(
      'GITLAB_KEY',
      'GITLAB_SECRET',
      client_options: { site: enterprise_site },
      redirect_url: 'http://localhost:9292/callback_url'
    )
  end

  subject { gitlab_service }

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  describe 'client options' do
    context 'with defaults' do
      subject { gitlab_service.options.client_options }

      its(:site) { is_expected.to eq 'https://gitlab.com' }
    end

    context 'with override' do
      subject { enterprise.options.client_options }

      its(:site) { is_expected.to eq enterprise_site }
    end
  end

  describe 'redirect_url' do
    context 'with defaults' do
      subject { gitlab_service.options }
      its(:redirect_url) { is_expected.to be_nil }
    end

    context 'with customs' do
      subject { enterprise.options }
      its(:redirect_url) { is_expected.to eq 'http://localhost:9292/callback_url' }
    end
  end

  describe '#raw_info' do
    it 'sent request to current user endpoint' do
      expect(access_token).to receive(:get).with('api/v4/user').and_return(response)
      expect(subject.raw_info).to eq(parsed_response)
    end
  end
end
