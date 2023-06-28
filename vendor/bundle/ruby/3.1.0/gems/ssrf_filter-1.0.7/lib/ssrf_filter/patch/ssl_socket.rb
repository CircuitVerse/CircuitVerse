class SsrfFilter
  module Patch
    module SSLSocket
      # When fetching a url we'd like to have the following workflow:
      # 1) resolve the hostname www.example.com, and choose a public ip address to connect to
      # 2) connect to that specific ip address, to prevent things like DNS TOCTTOU bugs or other trickery
      #
      # Ideally this would happen by the ruby http library giving us control over DNS resolution,
      # but it doesn't. Instead, when making the request we set the uri.hostname to the chosen ip address,
      # and send a 'Host' header of the original hostname, i.e. connect to 'http://93.184.216.34/' and send
      # a 'Host: www.example.com' header.
      #
      # This works for the http case, http://www.example.com. For the https case, this causes certificate
      # validation failures, since the server certificate for https://www.example.com will not have a
      # Subject Alternate Name for 93.184.216.34.
      #
      # Thus we perform the monkey-patch below, modifying SSLSocket's `post_connection_check(hostname)`
      # and `hostname=(hostname)` methods:
      # If our fiber local variable is set, use that for the hostname instead, otherwise behave as usual.
      # The only time the variable will be set is if you are executing inside a `with_forced_hostname` block,
      # which is used in ssrf_filter.rb.
      #
      # An alternative approach could be to pass in our own OpenSSL::X509::Store with a custom
      # `verify_callback` to the ::Net::HTTP.start call, but this would require reimplementing certification
      # validation, which is dangerous. This way we can piggyback on the existing validation and simply pretend
      # that we connected to the desired hostname.

      def self.apply!
        return if instance_variable_defined?(:@patched_ssl_socket)

        @patched_ssl_socket = true

        ::OpenSSL::SSL::SSLSocket.class_eval do
          original_post_connection_check = instance_method(:post_connection_check)
          define_method(:post_connection_check) do |hostname|
            original_post_connection_check.bind(self).call(::Thread.current[::SsrfFilter::FIBER_LOCAL_KEY] || hostname)
          end

          if method_defined?(:hostname=)
            original_hostname = instance_method(:hostname=)
            define_method(:hostname=) do |hostname|
              original_hostname.bind(self).call(::Thread.current[::SsrfFilter::FIBER_LOCAL_KEY] || hostname)
            end
          end
        end
      end
    end
  end
end
