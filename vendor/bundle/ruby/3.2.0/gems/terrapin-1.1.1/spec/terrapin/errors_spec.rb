require 'spec_helper'

describe "When an error happens" do
  it "raises a CommandLineError if the result code command isn't expected" do
    cmd = Terrapin::CommandLine.new("echo", "hello")
    expect(cmd).to receive(:execute)
    with_exitstatus_returning(1) do
      expect { cmd.run }.to raise_error(Terrapin::CommandLineError)
    end
  end

  it "does not raise if the result code is expected, even if nonzero" do
    cmd = Terrapin::CommandLine.new("echo", "hello", expected_outcodes: [0, 1])
    expect(cmd).to receive(:execute)
    with_exitstatus_returning(1) do
      expect { cmd.run }.not_to raise_error
    end
  end

  it "adds command output to exception message if the result code is nonzero" do
    cmd = Terrapin::CommandLine.new("echo", "hello")
    error_output = "Error 315"
    expect(cmd).to receive(:execute).and_return(Terrapin::CommandLine::Output.new("", error_output))
    with_exitstatus_returning(1) do
      begin
        cmd.run
      rescue Terrapin::ExitStatusError => e
        expect(e.message).to match(/STDERR:\s+#{error_output}/)
      end
    end
  end

  it 'passes the error message to the exception when command is not found' do
    cmd = Terrapin::CommandLine.new('test', '')
    expect(cmd).to receive(:execute).and_raise(Errno::ENOENT.new("not found"))
    begin
      cmd.run
    rescue Terrapin::CommandNotFoundError => e
      expect(e.message).to eq 'No such file or directory - not found'
    end
  end

  it "should keep result code in #exitstatus" do
    cmd = Terrapin::CommandLine.new("convert")
    expect(cmd).to receive(:execute).with("convert").and_return(:correct_value)
    with_exitstatus_returning(1) do
      cmd.run rescue nil
    end
    expect(cmd.exit_status).to eq(1)
  end

  it "does not blow up if running the command errored before execution" do
    cmd = Terrapin::CommandLine.new("echo", ":hello_world")
    expect(cmd).to receive(:command).and_raise("An Error")

    expect{ cmd.run }.to raise_error("An Error")
    expect(cmd.exit_status).to eq 0
  end
end
