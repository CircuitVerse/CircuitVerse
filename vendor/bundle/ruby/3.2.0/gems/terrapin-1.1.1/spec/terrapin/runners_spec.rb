require 'spec_helper'

describe "When picking a Runner" do
  it "uses the BackticksRunner by default" do
    expect(Terrapin::CommandLine::ProcessRunner).to receive(:supported?).and_return(false)

    cmd = Terrapin::CommandLine.new("echo", "hello")

    expect(cmd.runner.class).to eq(Terrapin::CommandLine::BackticksRunner)
  end

  it "uses the ProcessRunner on 1.9 and it's available" do
    expect(Terrapin::CommandLine::ProcessRunner).to receive(:supported?).and_return(true)

    cmd = Terrapin::CommandLine.new("echo", "hello")
    expect(cmd.runner.class).to eq(Terrapin::CommandLine::ProcessRunner)
  end

  it "uses the BackticksRunner if we told it to use Backticks all the time" do
    Terrapin::CommandLine.runner = Terrapin::CommandLine::BackticksRunner.new

    cmd = Terrapin::CommandLine.new("echo", "hello")
    expect(cmd.runner.class).to eq(Terrapin::CommandLine::BackticksRunner)
  end

  it "uses the BackticksRunner, if we told it to use Backticks" do
    cmd = Terrapin::CommandLine.new("echo", "hello", :runner => Terrapin::CommandLine::BackticksRunner.new)
    expect(cmd.runner.class).to eq(Terrapin::CommandLine::BackticksRunner)
  end

  it "can go into 'Fake' mode" do
    Terrapin::CommandLine.fake!

    cmd = Terrapin::CommandLine.new("echo", "hello")
    expect(cmd.runner.class).to eq Terrapin::CommandLine::FakeRunner
  end

  it "can turn off Fake mode" do
    Terrapin::CommandLine.fake!
    Terrapin::CommandLine.unfake!

    cmd = Terrapin::CommandLine.new("echo", "hello")
    expect(cmd.runner.class).not_to eq Terrapin::CommandLine::FakeRunner
  end

  it "can use a FakeRunner even if not in Fake mode" do
    Terrapin::CommandLine.unfake!

    cmd = Terrapin::CommandLine.new("echo", "hello", :runner => Terrapin::CommandLine::FakeRunner.new)
    expect(cmd.runner.class).to eq Terrapin::CommandLine::FakeRunner
  end
end

describe 'When running an executable in the supplemental path' do
  [
    Terrapin::CommandLine::BackticksRunner,
    Terrapin::CommandLine::PopenRunner,
    Terrapin::CommandLine::ProcessRunner
  ].each do |runner_class|
    if runner_class.supported?
      describe runner_class do
        describe '#run' do
          it 'finds the correct executable' do
            path = Pathname.new(File.dirname(__FILE__)) + '..' + 'support'
            File.open(path + 'ls', 'w'){|f| f.puts "#!/bin/sh\necho overridden-ls\n" }
            FileUtils.chmod(0755, path + 'ls')
            Terrapin::CommandLine.path = path
            Terrapin::CommandLine.runner = runner_class.new
            command = Terrapin::CommandLine.new('ls')

            result = command.run

            expect(result.strip).to eq('overridden-ls')

          ensure
            FileUtils.rm("#{Terrapin::CommandLine.path}/ls")
          end
        end
      end
    end
  end
end
