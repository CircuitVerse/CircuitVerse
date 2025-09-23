require 'base64'

module Playwright
  module Utils
    module PrepareBrowserContextOptions
      # @see https://github.com/microsoft/playwright/blob/5a2cfdbd47ed3c3deff77bb73e5fac34241f649d/src/client/browserContext.ts#L265
      private def prepare_browser_context_options(params)
        if params[:noViewport] == 0
          params.delete(:noViewport)
          params[:noDefaultViewport] = true
        end
        if params[:extraHTTPHeaders]
          params[:extraHTTPHeaders] = ::Playwright::HttpHeaders.new(params[:extraHTTPHeaders]).as_serialized
        end
        if params[:record_video_dir]
          params[:recordVideo] = {
            dir: params.delete(:record_video_dir)
          }
          if params[:record_video_size]
            params[:recordVideo][:size] = params.delete(:record_video_size)
          end
        end
        if params[:storageState].is_a?(String)
          params[:storageState] = JSON.parse(File.read(params[:storageState]))
        end

        %i[colorScheme reducedMotion forcedColors contrast].each do |key|
          if params[key] == 'null'
            params[key] = 'no-override'
          end
        end

        if params[:acceptDownloads] || params[:acceptDownloads] == false
          params[:acceptDownloads] = params[:acceptDownloads] ? 'accept' : 'deny'
        end

        if params[:clientCertificates].is_a?(Array)
          params[:clientCertificates] = params[:clientCertificates].filter_map do |item|
            out_record = {
              origin: item[:origin],
              passphrase: item[:passphrase],
            }

            { pfxPath: 'pfx', certPath: 'cert', keyPath: 'key' }.each do |key, out_key|
              if (filepath = item[key])
                out_record[out_key] = Base64.encode64(File.read(filepath)) rescue ''
              elsif (value = item[out_key.to_sym])
                out_record[out_key] = value
              end
            end

            out_record.compact!
            next nil if out_record.empty?

            out_record
          end
        end

        params
      end
    end

    module Errors
      module TargetClosedErrorMethods
        # @param err [Exception]
        private def target_closed_error?(err)
          err.is_a?(TargetClosedError)
        end
      end
    end
  end
end
