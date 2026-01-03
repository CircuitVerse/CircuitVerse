require 'spec_helper'

describe Terrapin::CommandLine do
  before do
    Terrapin::CommandLine.path = nil
    on_unix! # Assume we're on unix unless otherwise specified.
  end

  describe ".new" do
    it "treats nil params as blank" do
      cmd =  Terrapin::CommandLine.new("echo", nil)
      expect(cmd.run).to eq("\n")
    end

    it "raises when given nil options" do
      expect { Terrapin::CommandLine.new("echo", "", nil) }
        .to raise_error(ArgumentError)
    end
  end

  it "takes a command and parameters and produces a Bash command line" do
    cmd = Terrapin::CommandLine.new("convert", "a.jpg b.png", :swallow_stderr => false)
    expect(cmd.command).to eq("convert a.jpg b.png")
  end

  it "specifies the $PATH where the command can be found on unix" do
    Terrapin::CommandLine.path = ["/path/to/command/dir", "/"]
    cmd = Terrapin::CommandLine.new("ls")
    expect(cmd.command).to eq("PATH=/path/to/command/dir:/:$PATH; ls")
  end

  it "specifies the %PATH% where the command can be found on windows" do
    on_windows!
    Terrapin::CommandLine.path = ['C:\system32', 'D:\\']
    cmd = Terrapin::CommandLine.new("dir")
    expect(cmd.command).to eq('SET PATH=C:\system32;D:\;%PATH% & dir')
  end

  it "specifies more than one path where the command can be found" do
    Terrapin::CommandLine.path = ["/path/to/command/dir", "/some/other/path"]
    cmd = Terrapin::CommandLine.new("ruby", "-e 'puts ENV[%{PATH}]'")
    output = cmd.run
    expect(output).to match(%r{/path/to/command/dir})
    expect(output).to match(%r{/some/other/path})
  end

  it "temporarily changes specified environment variables" do
    Terrapin::CommandLine.environment['TEST'] = 'Hello, world!'
    cmd = Terrapin::CommandLine.new("ruby", "-e 'puts ENV[%{TEST}]'")
    output = cmd.run
    expect(output).to match(%r{Hello, world!})
  end

  it 'changes environment variables for the command line' do
    Terrapin::CommandLine.environment['TEST'] = 'Hello, world!'
    cmd = Terrapin::CommandLine.new("ruby",
                                   "-e 'puts ENV[%{TEST}]'",
                                   :environment => {'TEST' => 'Hej hej'})
    output = cmd.run
    expect(output).to match(%r{Hej hej})
  end

  it 'passes the existing environment variables through to the runner' do
    command = Terrapin::CommandLine.new('echo', '$HOME')
    output = command.run
    expect(output.chomp).not_to eq('')
  end

  it "can interpolate quoted variables into the command line's parameters" do
    cmd = Terrapin::CommandLine.new("convert",
                                   ":one :{two}",
                                   :swallow_stderr => false)

    command_string = cmd.command(:one => "a.jpg", :two => "b.png")
    expect(command_string).to eq("convert 'a.jpg' 'b.png'")
  end

  it 'does not over-interpolate in a command line' do
    cmd = Terrapin::CommandLine.new("convert",
                                   ":hell :{two} :hello",
                                   :swallow_stderr => false)

    command_string = cmd.command(:hell => "a.jpg", :two => "b.png", :hello => "c.tiff")
    expect(command_string).to eq("convert 'a.jpg' 'b.png' 'c.tiff'")
  end

  it "interpolates when running a command" do
    command = Terrapin::CommandLine.new("echo", ":hello_world")
    expect(command.run(:hello_world => "Hello, world")).to match(/Hello, world/)
  end

  it "interpolates any Array arguments when running a command" do
    command = Terrapin::CommandLine.new("echo", "Hello :worlds and :dwarfs")
    expect(command.command(:worlds => %w[mercury venus earth], :dwarfs => "pluto")).to eq("echo Hello 'mercury' 'venus' 'earth' and 'pluto'")
  end

  it "quotes command line options differently if we're on windows" do
    on_windows!
    cmd = Terrapin::CommandLine.new("convert",
                                   ":one :{two}",
                                   :swallow_stderr => false)
    command_string = cmd.command(:one => "a.jpg", :two => "b.png")
    expect(command_string).to eq('convert "a.jpg" "b.png"')
  end

  it "can quote and interpolate dangerous variables" do
    cmd = Terrapin::CommandLine.new("convert",
                                   ":one :two",
                                   :swallow_stderr => false)
    command_string = cmd.command(:one => "`rm -rf`.jpg", :two => "ha'ha.png'")
    expect(command_string).to eq("convert '`rm -rf`.jpg' 'ha'\\''ha.png'\\'''")
  end

  it 'cannot recursively introduce a place where user-supplied commands can run' do
    cmd = Terrapin::CommandLine.new('convert', ':foo :bar')
    expect(cmd.command(:foo => ':bar', :bar => '`rm -rf`')).to eq('convert \':bar\' \'`rm -rf`\'')
  end

  it "can quote and interpolate dangerous variables even on windows" do
    on_windows!
    cmd = Terrapin::CommandLine.new("convert",
                                   ":one :two",
                                   :swallow_stderr => false)
    command_string = cmd.command(:one => "`rm -rf`.jpg", :two => "ha'ha.png")
    expect(command_string).to eq(%{convert "`rm -rf`.jpg" "ha'ha.png"})
  end

  it "quotes blank values into the command line's parameters" do
    cmd = Terrapin::CommandLine.new("curl",
                                   "-X POST -d :data :url",
                                   :swallow_stderr => false)
    command_string = cmd.command(:data => "", :url => "http://localhost:9000")
    expect(command_string).to eq("curl -X POST -d '' 'http://localhost:9000'")
  end

  it "allows colons in parameters" do
    cmd = Terrapin::CommandLine.new("convert", "'a.jpg' xc:black 'b.jpg'", :swallow_stderr => false)
    expect(cmd.command).to eq("convert 'a.jpg' xc:black 'b.jpg'")
  end

  it 'handles symbols in user supplied values' do
    cmd = Terrapin::CommandLine.new("echo", ":foo")
    command_string = cmd.command(:foo => :bar)
    expect(command_string).to eq("echo 'bar'")
  end

  it "can redirect stderr to the bit bucket if requested" do
    cmd = Terrapin::CommandLine.new("convert",
                                   "a.jpg b.png",
                                   :swallow_stderr => true)

    expect(cmd.command).to eq("convert a.jpg b.png 2>/dev/null")
  end

  it "can redirect stderr to the bit bucket on windows" do
    on_windows!
    cmd = Terrapin::CommandLine.new("convert",
                                   "a.jpg b.png",
                                   :swallow_stderr => true)

    expect(cmd.command).to eq("convert a.jpg b.png 2>NUL")
  end

  it "runs the command it's given and returns the output" do
    cmd = Terrapin::CommandLine.new("echo", "hello", :swallow_stderr => false)
    expect(cmd.run).to eq "hello\n"
  end

  it "runs the command it's given and allows access to stdout afterwards" do
    cmd = Terrapin::CommandLine.new("echo", "hello", :swallow_stderr => false)
    cmd.run
    expect(cmd.command_output).to eq "hello\n"
  end

  it "colorizes the output to a tty" do
    logger = FakeLogger.new(:tty => true)
    Terrapin::CommandLine.new("echo", "'Logging!' :foo", :logger => logger).run(:foo => "bar")
    expect(logger.entries).to include("\e[32mCommand\e[0m :: echo 'Logging!' 'bar'")
  end

  it 'can still take something that does not respond to tty as a logger' do
    output_buffer = StringIO.new
    logger = best_logger.new(output_buffer)
    expect(logger).not_to respond_to(:tty?)
    Terrapin::CommandLine.new("echo", "'Logging!' :foo", :logger => logger).run(:foo => "bar")
    output_buffer.rewind
    expect(output_buffer.read).to eq("Command :: echo 'Logging!' 'bar'\n")
  end

  it "logs the command to a supplied logger" do
    logger = FakeLogger.new
    Terrapin::CommandLine.new("echo", "'Logging!' :foo", :logger => logger).run(:foo => "bar")
    expect(logger.entries).to include("Command :: echo 'Logging!' 'bar'")
  end

  it "logs the command to a default logger" do
    Terrapin::CommandLine.logger = FakeLogger.new
    Terrapin::CommandLine.new("echo", "'Logging!'").run
    expect(Terrapin::CommandLine.logger.entries).to include("Command :: echo 'Logging!'")
  end

  it "is fine if no logger is supplied" do
    Terrapin::CommandLine.logger = nil
    cmd = Terrapin::CommandLine.new("echo", "'Logging!'", :logger => nil)
    expect { cmd.run }.not_to raise_error
  end
end
