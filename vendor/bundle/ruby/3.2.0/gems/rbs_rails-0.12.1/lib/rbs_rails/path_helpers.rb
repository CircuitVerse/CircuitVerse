module RbsRails
  class PathHelpers
    def self.generate(routes: Rails.application.routes)
      new(routes: Rails.application.routes).generate
    end

    def initialize(routes:)
      @routes = routes
    end

    def generate
      methods = helpers.map do |helper|
        # TODO: More restrict argument types
        "def #{helper}: (*untyped) -> String"
      end

      <<~RBS
        interface _RbsRailsPathHelpers
        #{methods.join("\n").indent(2)}
        end
      RBS
    end

    private def helpers
      routes.named_routes.helper_names
    end

    private
    # @dynamic routes
    attr_reader :routes
  end
end
