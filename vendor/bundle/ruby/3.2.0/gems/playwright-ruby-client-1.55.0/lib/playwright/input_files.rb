require 'base64'

module Playwright
  class InputFiles
    def initialize(context, files)
      @context = context
      if files.is_a?(File)
        files_to_resolve = [files]
      elsif files.is_a?(Enumerable)
        files_to_resolve = files
      else
        files_to_resolve = [files]
      end
      resolve_paths_and_directory_for_input_files(files_to_resolve)
    end

    def as_method_and_params
      if @local_directory || has_large_file?
        ['setInputFiles', params_for_set_input_file_paths]
      else
        ['setInputFiles', params_for_set_input_files]
      end
    end

    private def has_large_file?
      max_bufsize = 1024 * 1024 # 1MB

      @local_files.any? do |file|
        case file
        when String
          File::Stat.new(file).size > max_bufsize
        when File
          file.stat.size > max_bufsize
        end
      end
    end

    private def resolve_paths_and_directory_for_input_files(files)
      # filter_map is not available in Ruby < 2.7
      @local_files = files.map do |item|
        case item
        when String
          if File.directory?(item)
            raise ArgumentError.new('Multiple directories are not supported') if @local_directory
            @local_directory = item
            next
          end

          item
        when File
          if File.directory?(item.path)
            raise ArgumentError.new('Multiple directories are not supported') if @local_directory
            @local_directory = item
            next
          end

          item
        else
          raise ArgumentError.new('file must be a String or File or Directory.')
        end
      end.compact

      if @local_directory && !@local_files.empty?
        raise ArgumentError.new('File paths must be all files or a single directory')
      end
    end

    private def params_for_set_input_file_paths
      if @local_directory
        filenames = Dir["#{@local_directory}/**/*"].reject { |file| File.directory?(file) }
        directory_stream, writable_streams = @context.send(:create_temp_files, @local_directory, filenames)

        filenames.zip(writable_streams).each do |filename, writable_stream|
          File.open(filename, 'rb') do |file|
            writable_stream.write(file)
          end
        end

        { directoryStream: directory_stream.channel }
      else
        filenames = @local_files.map do |file|
          case file
          when String
            file
          when File
            file.path
          end
        end

        _, writable_streams = @context.send(:create_temp_files, nil, filenames)
        @local_files.zip(writable_streams).each do |file, writable_stream|
          case file
          when String
            File.open(file, 'rb') do |file|
              writable_stream.write(file)
            end
          when File
            writable_stream.write(file)
          end
        end

        { streams: writable_streams.map(&:channel) }
      end
    end

    private def params_for_set_input_files
      file_payloads = @local_files.map do |file|
        case file
        when String
          {
            name: File.basename(file),
            buffer: Base64.strict_encode64(File.read(file)),
          }
        when File
          {
            name: File.basename(file.path),
            buffer: Base64.strict_encode64(file.read),
          }
        end
      end

      { payloads: file_payloads }
    end

    private def raise_argument_error
      raise ArgumentError.new('file must be a String or File.')
    end
  end
end
