module StubOS
  def on_windows!
    stub_os('mswin')
    allow(Terrapin::OS).to receive(:path_separator).and_return(";")
  end

  def on_unix!
    stub_os('darwin11.0.0')
    allow(Terrapin::OS).to receive(:path_separator).and_return(":")
  end

  def on_mingw!
    stub_os('mingw')
    allow(Terrapin::OS).to receive(:path_separator).and_return(";")
  end

  def on_java!
    allow(Terrapin::OS).to receive(:arch).and_return("universal-java1.7")
  end

  def stub_os(host_string)
    # http://blog.emptyway.com/2009/11/03/proper-way-to-detect-windows-platform-in-ruby/
    allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return(host_string)
  end
end
