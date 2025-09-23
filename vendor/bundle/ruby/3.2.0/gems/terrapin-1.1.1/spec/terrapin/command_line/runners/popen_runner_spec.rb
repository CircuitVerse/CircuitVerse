require 'spec_helper'

describe Terrapin::CommandLine::PopenRunner do
  if Terrapin::CommandLine::PopenRunner.supported?
    it_behaves_like 'a command that does not block', { :supports_stderr => false }

    it 'runs the command given and captures the output in an Output' do
      output = subject.call("echo hello")
      expect(output).to have_output "hello\n"
    end

    it 'modifies the environment and runs the command given' do
      output = subject.call("echo $yes", {"yes" => "no"})
      expect(output).to have_output "no\n"
    end

    it 'sets the exitstatus when a command completes' do
      subject.call("ruby -e 'exit 0'")
      expect($?.exitstatus).to eq(0)
      subject.call("ruby -e 'exit 5'")
      expect($?.exitstatus).to eq(5)
    end
  end
end
