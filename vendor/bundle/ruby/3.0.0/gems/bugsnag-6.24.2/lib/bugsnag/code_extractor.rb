module Bugsnag
  # @api private
  class CodeExtractor
    MAXIMUM_LINES_TO_KEEP = 7

    ##
    # @param configuration [Configuration]
    def initialize(configuration)
      @files = {}
      @configuration = configuration
    end

    ##
    # Add a file and its corresponding trace hash to be processed.
    #
    # @param path [String] The full path to the file
    # @param trace [Hash]
    # @return [void]
    def add_file(path, trace)
      # If the file doesn't exist we can't extract code from it, so we can skip
      # this file entirely
      unless File.exist?(path)
        trace[:code] = nil

        return
      end

      @files[path] ||= []
      @files[path].push(trace)

      # Record the line numbers we want to fetch for this trace
      # We grab extra lines so that we can compensate if the error is on the
      # first or last line of a file
      first_line_number = trace[:lineNumber] - MAXIMUM_LINES_TO_KEEP

      trace[:first_line_number] = first_line_number < 1 ? 1 : first_line_number
      trace[:last_line_number] = trace[:lineNumber] + MAXIMUM_LINES_TO_KEEP
    end

    ##
    # Add the code to the hashes that were given in {#add_file} by modifying
    # them in-place. They will have a new ':code' key containing a hash of line
    # number => string of code for that line
    #
    # @return [void]
    def extract!
      @files.each do |path, traces|
        begin
          line_numbers = Set.new

          traces.each do |trace|
            trace[:first_line_number].upto(trace[:last_line_number]) do |line_number|
              line_numbers << line_number
            end
          end

          extract_from(path, traces, line_numbers)
        rescue StandardError => e
          # Clean up after ourselves
          traces.each do |trace|
            trace[:code] ||= nil
            trace.delete(:first_line_number)
            trace.delete(:last_line_number)
          end

          @configuration.warn("Error extracting code: #{e.inspect}")
        end
      end
    end

    private

    ##
    # @param path [String]
    # @param traces [Array<Hash>]
    # @param line_numbers [Set<Integer>]
    # @return [void]
    def extract_from(path, traces, line_numbers)
      code = {}

      File.open(path) do |file|
        current_line_number = 0

        file.each_line do |line|
          current_line_number += 1

          next unless line_numbers.include?(current_line_number)

          code[current_line_number] = line[0...200].rstrip
        end
      end

      associate_code_with_trace(code, traces)
    end

    ##
    # @param code [Hash{Integer => String}]
    # @param traces [Array<Hash>]
    # @return [void]
    def associate_code_with_trace(code, traces)
      traces.each do |trace|
        trace[:code] = {}

        code.each do |line_number, line|
          # If we've gone past the last line we care about, we can stop iterating
          break if line_number > trace[:last_line_number]

          # Skip lines that aren't in the range we want
          next unless line_number >= trace[:first_line_number]

          trace[:code][line_number] = line
        end

        trim_excess_lines(trace[:code], trace[:lineNumber])
        trace.delete(:first_line_number)
        trace.delete(:last_line_number)
      end
    end

    ##
    # @param code [Hash{Integer => String}]
    # @param line_number [Integer]
    # @return [void]
    def trim_excess_lines(code, line_number)
      while code.length > MAXIMUM_LINES_TO_KEEP
        last_line = code.keys.max
        first_line = code.keys.min

        if (last_line - line_number) > (line_number - first_line)
          code.delete(last_line)
        else
          code.delete(first_line)
        end
      end
    end
  end
end
