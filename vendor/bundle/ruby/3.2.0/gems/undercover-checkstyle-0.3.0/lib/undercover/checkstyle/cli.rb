# frozen_string_literal: true

require 'undercover'
require 'undercover/checkstyle/formatter'

module Undercover
  module Checkstyle
    module CLI
      def self.run(args)
        opts = Undercover::Options.new.parse(args)
        syntax_version(opts.syntax_version)

        run_report(opts)
      end

      def self.run_report(opts)
        report = Undercover::Report.new(changeset(opts), opts).build
        flagged = report.flagged_results
        puts Undercover::Checkstyle::Formatter.new(flagged)
        flagged.any? ? 1 : 0
      end

      def self.syntax_version(version)
        return unless version

        Imagen.parser_version = version
      end

      def self.changeset(opts)
        git_dir = File.join(opts.path, opts.git_dir)
        Undercover::Changeset.new(git_dir, opts.compare)
      end
    end
  end
end
