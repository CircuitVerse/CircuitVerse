describe "ActivityNotification.gem_version" do
  it "returns gem version" do
    expect(ActivityNotification.gem_version.to_s).to eq(ActivityNotification::VERSION)
  end
end

describe ActivityNotification::GEM_VERSION do
  describe "MAJOR" do
    it "returns gem major version" do
      expect(ActivityNotification::GEM_VERSION::MAJOR).to eq(ActivityNotification::VERSION.split(".")[0])
    end
  end

  describe "MINOR" do
    it "returns gem minor version" do
      expect(ActivityNotification::GEM_VERSION::MINOR).to eq(ActivityNotification::VERSION.split(".")[1])
    end
  end

  describe "TINY" do
    it "returns gem tiny version" do
      expect(ActivityNotification::GEM_VERSION::TINY).to eq(ActivityNotification::VERSION.split(".")[2])
    end
  end

  describe "PRE" do
    it "returns gem pre version" do
      expect(ActivityNotification::GEM_VERSION::PRE).to eq(ActivityNotification::VERSION.split(".")[3])
    end
  end
end
