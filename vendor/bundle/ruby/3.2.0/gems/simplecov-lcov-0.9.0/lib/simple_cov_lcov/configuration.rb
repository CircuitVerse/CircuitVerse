module SimpleCovLcov
  class Configuration
    attr_writer :report_with_single_file
    attr_writer :output_directory
    attr_writer :lcov_file_name

    def report_with_single_file?
      !!@report_with_single_file
    end

    def output_directory
      @output_directory || File.join(SimpleCov.coverage_path, 'lcov')
    end

    def single_report_path=(new_path)
      self.output_directory = File.dirname(new_path)
      @single_report_path = new_path
    end

    def single_report_path
      @single_report_path ||= File.join(output_directory, lcov_file_name)
    end

    def lcov_file_name
      @lcov_file_name || "#{Pathname.new(SimpleCov.root).basename}.lcov"
    end
  end
end
