module ActivityNotification
  # Returns the version of the currently loaded ActivityNotification as a Gem::Version
  def self.gem_version
    Gem::Version.new VERSION
  end

  # Manages individual gem version from Gem::Version
  module GEM_VERSION
    MAJOR = VERSION.split(".")[0]
    MINOR = VERSION.split(".")[1]
    TINY  = VERSION.split(".")[2]
    PRE   = VERSION.split(".")[3]
  end
end
