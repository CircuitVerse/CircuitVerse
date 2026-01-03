module HairTrigger
  class Configuration
    attr_accessor :postgresql_adapters, :mysql_adapters, :sqlite_adapters

    def initialize(postgresql_adapters: [], mysql_adapters: [], sqlite_adapters: [])
      @postgresql_adapters = postgresql_adapters
      @mysql_adapters      = mysql_adapters
      @sqlite_adapters     = sqlite_adapters
    end
  end
end
