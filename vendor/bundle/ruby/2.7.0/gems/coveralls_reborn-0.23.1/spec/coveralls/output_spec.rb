# frozen_string_literal: true

require 'spec_helper'

describe Coveralls::Output do
  it 'defaults the IO to $stdout' do
    expect { described_class.puts 'this is a test' }.to output("this is a test\n").to_stdout
  end

  it 'accepts an IO injection' do
    out = StringIO.new
    allow(described_class).to receive(:output).and_return(out)
    described_class.puts 'this is a test'

    expect(out.string).to eq "this is a test\n"
  end

  describe '.puts' do
    it 'accepts an IO injection' do
      out = StringIO.new
      described_class.puts 'this is a test', output: out

      expect(out.string).to eq "this is a test\n"
    end
  end

  describe '.print' do
    it 'accepts an IO injection' do
      out = StringIO.new
      described_class.print 'this is a test', output: out

      expect(out.string).to eq 'this is a test'
    end
  end

  describe 'when silenced' do
    before { described_class.silent = true }

    it 'does not put' do
      expect { described_class.puts 'foo' }.not_to output("foo\n").to_stdout
    end

    it 'does not print' do
      expect { described_class.print 'foo' }.not_to output('foo').to_stdout
    end
  end

  describe '.format' do
    it 'accepts a color argument' do
      require 'term/ansicolor'
      string = 'Hello'
      ansi_color_string = Term::ANSIColor.red(string)
      expect(described_class.format(string, color: 'red')).to eq(ansi_color_string)
    end

    it 'accepts no color arguments' do
      unformatted_string = 'Hi Doggie!'
      expect(described_class.format(unformatted_string)).to eq(unformatted_string)
    end

    it 'rejects formats unrecognized by Term::ANSIColor' do
      string = 'Hi dog!'
      expect(described_class.format(string, color: 'not_a_real_color')).to eq(string)
    end

    it 'accepts more than 1 color argument' do
      string = 'Hi dog!'
      multi_formatted_string = Term::ANSIColor.red { Term::ANSIColor.underline(string) }
      expect(described_class.format(string, color: 'red underline')).to eq(multi_formatted_string)
    end

    context 'without color' do
      before { described_class.no_color = true }

      it 'does not add color to string' do
        unformatted_string = 'Hi Doggie!'
        expect(described_class.format(unformatted_string, color: 'red')).to eq(unformatted_string)
      end
    end
  end
end
