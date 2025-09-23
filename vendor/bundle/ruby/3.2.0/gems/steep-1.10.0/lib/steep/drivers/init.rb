module Steep
  module Drivers
    class Init
      attr_reader :stdout
      attr_reader :stderr
      attr_accessor :force_write

      include Utils::DriverHelper

      TEMPLATE = <<~EOF
      # D = Steep::Diagnostic
      #
      # target :lib do
      #   signature "sig"
      #   ignore_signature "sig/test"
      #
      #   check "lib"                       # Directory name
      #   check "path/to/source.rb"         # File name
      #   check "app/models/**/*.rb"        # Glob
      #   # ignore "lib/templates/*.rb"
      #
      #   # library "pathname"              # Standard libraries
      #   # library "strong_json"           # Gems
      #
      #   # configure_code_diagnostics(D::Ruby.default)      # `default` diagnostics setting (applies by default)
      #   # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
      #   # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
      #   # configure_code_diagnostics(D::Ruby.silent)       # `silent` diagnostics setting
      #   # configure_code_diagnostics do |hash|             # You can setup everything yourself
      #   #   hash[D::Ruby::NoMethod] = :information
      #   # end
      # end

      # target :test do
      #   unreferenced!                     # Skip type checking the `lib` code when types in `test` target is changed
      #   signature "sig/test"              # Put RBS files for tests under `sig/test`
      #   check "test"                      # Type check Ruby scripts under `test`
      #
      #   configure_code_diagnostics(D::Ruby.lenient)      # Weak type checking for test code
      #
      #   # library "pathname"              # Standard libraries
      # end
      EOF

      def initialize(stdout:, stderr:)
        @stdout = stdout
        @stderr = stderr
        @force_write = false
      end

      def run
        path = steepfile || Pathname("Steepfile")

        if path.file? && !force_write
          stdout.puts "#{path} already exists, --force to overwrite"
          return 1
        end

        stdout.puts "Writing #{path}..."
        path.write(TEMPLATE)

        0
      end
    end
  end
end
