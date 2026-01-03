require 'spec_helper'

describe Terrapin::OSDetector do
  it "detects that the system is unix" do
    on_unix!
    expect(Terrapin::OS).to be_unix
  end

  it "detects that the system is windows" do
    on_windows!
    expect(Terrapin::OS).to be_windows
  end

  it "detects that the system is windows (mingw)" do
    on_mingw!
    expect(Terrapin::OS).to be_windows
  end

  it "detects that the current Ruby is on Java" do
    on_java!
    expect(Terrapin::OS).to be_java
  end
end
