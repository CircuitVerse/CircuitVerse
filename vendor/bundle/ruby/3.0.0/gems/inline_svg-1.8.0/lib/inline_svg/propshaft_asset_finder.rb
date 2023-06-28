module InlineSvg
  class PropshaftAssetFinder
    def self.find_asset(filename)
      new(filename)
    end

    def initialize(filename)
      @filename = filename
    end

    def pathname
      ::Rails.application.assets.load_path.find(@filename).path
    end
  end
end
