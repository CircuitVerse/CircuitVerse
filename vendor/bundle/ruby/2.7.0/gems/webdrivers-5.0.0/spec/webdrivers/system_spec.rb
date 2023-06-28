# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::System do
  describe '#wsl_v1?' do
    subject { described_class.wsl_v1? }

    before do
      allow(described_class).to receive(:platform).and_return(platform)
      allow(File).to receive(:open).with('/proc/version').and_return(StringIO.new(wsl_proc_version_contents))
    end

    let(:platform) { 'linux' }
    let(:wsl_proc_version_contents) { '' }

    context 'when the current platform is linux and WSL version is 1' do
      let(:wsl_proc_version_contents) do
        'Linux version 4.4.0-18362-Microsoft'\
        '(Microsoft@Microsoft.com) (gcc version 5.4.0 (GCC) )'\
        '#836-Microsoft Mon May 05 16:04:00 PST 2020'
      end

      it { is_expected.to eq true }
    end

    context 'when the current platform is linux and WSL version is 2' do
      let(:wsl_proc_version_contents) do
        'Linux version 4.19.84-microsoft-standard '\
        '(oe-user@oe-host) (gcc version 8.2.0 (GCC)) '\
        '#1 SMP Wed Nov 13 11:44:37 UTC 2019'
      end

      it { is_expected.to eq false }
    end

    context 'when the current platform is mac' do
      let(:platform) { 'mac' }

      it { is_expected.to eq false }
    end
  end

  describe '#to_win32_path' do
    before { allow(described_class).to receive(:call).and_return("C:\\path\\to\\folder\n") }

    it 'uses wslpath' do
      described_class.to_win32_path '/c/path/to/folder'

      expect(described_class).to have_received(:call).with('wslpath -w \'/c/path/to/folder\'')
    end

    it 'removes the trailing newline' do
      expect(described_class.to_win32_path('/c/path/to/folder')).not_to end_with('\n')
    end

    context 'when the path is already in Windows format' do
      it 'returns early' do
        expect(described_class.to_win32_path('D:\\')).to eq 'D:\\'

        expect(described_class).not_to have_received(:call)
      end
    end
  end

  describe '#to_wsl_path' do
    before { allow(described_class).to receive(:call).and_return("/c/path/to/folder\n") }

    it 'uses wslpath' do
      described_class.to_wsl_path 'C:\\path\\to\\folder'

      expect(described_class).to have_received(:call).with('wslpath -u \'C:\\path\\to\\folder\'')
    end

    it 'removes the trailing newline' do
      expect(described_class.to_wsl_path('/c/path/to/folder')).not_to end_with('\n')
    end
  end
end
