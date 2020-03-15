# frozen_string_literal: true

module WebConsole
  # Injects content into a Rack body.
  class Injector
    def initialize(body, headers)
      @body = "".dup

      body.each { |part| @body << part }
      body.close if body.respond_to?(:close)

      @headers = headers
    end

    def inject(content)
      # Remove any previously set Content-Length header because we modify
      # the body. Otherwise the response will be truncated.
      @headers.delete("Content-Length")

      [
        if position = @body.rindex("</body>")
          [ @body.insert(position, content) ]
        else
          [ @body << content ]
        end,
        @headers
      ]
    end
  end
end
