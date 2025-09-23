module InlineSvg
  class WebpackAssetFinder
    def self.find_asset(filename)
      new(filename)
    end

    def initialize(filename)
      @filename = filename
      manifest_lookup = asset_helper.manifest.lookup(@filename)
      @asset_path =  manifest_lookup.present? ? URI(manifest_lookup).path : ""
    end

    def pathname
      return if @asset_path.blank?

      if asset_helper.dev_server.running?
        dev_server_asset(@asset_path)
      elsif asset_helper.config.public_path.present?
        File.join(asset_helper.config.public_path, @asset_path)
      end
    end

    private

    def asset_helper
      @asset_helper ||=
        if defined?(::Shakapacker)
          ::Shakapacker
        else
          ::Webpacker
        end
    end

    def dev_server_asset(file_path)
      asset = fetch_from_dev_server(file_path)

      begin
        Tempfile.new(file_path).tap do |file|
          file.binmode
          file.write(asset)
          file.rewind
        end
      rescue StandardError => e
        Rails.logger.error "[inline_svg] Error creating tempfile for #{@filename}: #{e}"
        raise
      end
    end

    def fetch_from_dev_server(file_path)
      http = Net::HTTP.new(asset_helper.dev_server.host, asset_helper.dev_server.port)
      http.use_ssl = asset_helper.dev_server.protocol == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.request(Net::HTTP::Get.new(file_path)).body
    rescue StandardError => e
      Rails.logger.error "[inline_svg] Error fetching #{@filename} from webpack-dev-server: #{e}"
      raise
    end
  end
end
