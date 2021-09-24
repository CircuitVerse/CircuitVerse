require 'rails'

module Remotipart
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      desc "This generator installs IframeTransport.js #{Remotipart::Rails::IFRAMETRANSPORT_VERSION} and Remotipart #{Remotipart::Rails::VERSION}"
      source_root File.expand_path('../../../../../vendor/assets/javascripts', __FILE__)

      def install_iframe_transport
        say_status "copying", "IframeTransport.js #{Remotipart::Rails::IFRAMETRANSPORT_VERSION}", :green
        copy_file "jquery.iframe-transport.js", "public/javascripts/jquery.iframe-transport.js"
      end

      def install_remotipart
        say_status "copying", "Remotipart.js #{Remotipart::Rails::VERSION}", :green
        copy_file 'jquery.remotipart.js', 'public/javascripts/jquery.remotipart.js'
      end
    end
  end
end
