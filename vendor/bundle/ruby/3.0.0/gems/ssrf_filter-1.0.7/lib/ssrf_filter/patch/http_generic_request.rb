require 'stringio'

class SsrfFilter
  module Patch
    module HTTPGenericRequest
      # Ruby had a bug in its Http library where if you set a custom `Host` header on a request it would get
      # overwritten. This was tracked in:
      # https://bugs.ruby-lang.org/issues/10054
      # and resolved with the commit:
      # https://github.com/ruby/ruby/commit/70a2eb63999265ff7e8d46d1f5b410c8ee3d30d7#diff-5c08b4ae27d2294a8294a27ff9af4a85
      # Versions of Ruby that don't have this fix applied will fail to connect to certain hosts via SsrfFilter. The
      # patch below backports the fix from the linked commit.

      def self.should_apply?
        # Check if the patch needs to be applied:
        # The Ruby bug was that HTTPGenericRequest#exec overwrote the Host header, so this snippet checks
        # if we can reproduce that behavior. It does not actually open any network connections.

        uri = URI('https://www.example.com')
        request = ::Net::HTTPGenericRequest.new('HEAD', false, false, uri)
        request['host'] = '127.0.0.1'
        request.exec(StringIO.new, '1.1', '/')
        request['host'] == uri.hostname
      end

      # Apply the patch from the linked commit onto ::Net::HTTPGenericRequest. Since this is 3rd party code,
      # disable code coverage and rubocop linting for this section.
      # :nocov:
      # rubocop:disable all
      def self.apply!
        return if instance_variable_defined?(:@checked_http_generic_request)
        @checked_http_generic_request = true
        return unless should_apply?

        ::Net::HTTPGenericRequest.class_eval do
          def exec(sock, ver, path)
            if @body
              send_request_with_body sock, ver, path, @body
            elsif @body_stream
              send_request_with_body_stream sock, ver, path, @body_stream
            elsif @body_data
              send_request_with_body_data sock, ver, path, @body_data
            else
              write_header sock, ver, path
            end
          end

          def update_uri(addr, port, ssl)
            # reflect the connection and @path to @uri
            return unless @uri

            if ssl
              scheme = 'https'.freeze
              klass = URI::HTTPS
            else
              scheme = 'http'.freeze
              klass = URI::HTTP
            end

            if host = self['host']
              host.sub!(/:.*/s, ''.freeze)
            elsif host = @uri.host
            else
             host = addr
            end
            # convert the class of the URI
            if @uri.is_a?(klass)
              @uri.host = host
              @uri.port = port
            else
              @uri = klass.new(
                scheme, @uri.userinfo,
                host, port, nil,
                @uri.path, nil, @uri.query, nil)
            end
          end
        end
      end
      # rubocop:enable all
      # :nocov:
    end
  end
end
