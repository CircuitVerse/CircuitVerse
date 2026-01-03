module Lookbook
  module LocatableEntity
    extend ActiveSupport::Concern

    included do
      # @!group Paths

      # Full path to the entity file
      #
      # @return [Pathname] File patj
      attr_reader :file_path

      # @api private
      attr_reader :base_directories

      # Name of the entity file.
      #
      # Includes file extension unless the `strip_ext` argument is `true`.
      #
      # @param strip_ext [Boolean] Whether or not to remove the file extension
      # @return [String] File name
      def file_name(strip_ext = false)
        basename = file_pathname.basename
        (strip_ext ? basename.to_s.split(".").first : basename).to_s
      end

      # Extension of the entity file.
      #
      # @return [String] File extension
      def file_extension
        @_file_extension ||= file_pathname.extname
      end

      # Full directory path for the entity file.
      #
      # @return [Pathname] Directory path
      def directory_path
        @_directory_path ||= Pathname(file_pathname.dirname)
      end

      # Relative path to the entity file.
      #
      # Returned path is relative to the appropriate base directory
      # (i.e. the preview directory for previews).
      #
      # @return [Pathname] Relative file path
      def relative_file_path
        @_relative_file_path ||= file_pathname.relative_path_from(base_directory)
      end

      # Relative directory path for the entity file.
      #
      # Returned path is relative to the appropriate base directory
      # (i.e. the preview directory for previews).
      #
      # @return [Pathname] Relative directory path
      def relative_directory_path
        @_relative_directory_path ||= directory_path.relative_path_from(base_directory)
      end

      # Time that the entity file was last modified
      #
      # @return [Time] Time last modified
      def last_modified
        @_last_modified ||= File.mtime(file_path)
      end

      # 'Virtual' path to the entity.
      #
      # Determines where the entity is located in heirarchical trees.
      # Can be altered using the `@logical_path` tag.
      #
      # @api private
      # @return [String] The logical path
      def logical_path
        return @_logical_path if @_logical_path

        logical_path_value = fetch_config(:logical_path)

        @_logical_path ||= if logical_path_value
          PathUtils.to_path(logical_path_value, lookup_path.split("/").last)
        else
          PathUtils.to_path(lookup_path)
        end
      end

      # @!endgroup

      # @api private
      def file_name_base
        @_file_name_slug ||= file_name(true)
      end

      alias_method :full_path, :file_path
      alias_method :rel_path, :relative_file_path
      alias_method :dir_path, :directory_path

      deprecate full_path: :file_path, deprecator: Deprecation
      deprecate rel_path: :relative_file_path, deprecator: Deprecation
      deprecate dir_path: :directory_path, deprecator: Deprecation

      protected

      def file_pathname
        Pathname(file_path)
      end

      def base_directory
        return @_base_directory if @_base_directory

        directories = Array(base_directories).map(&:to_s).sort_by { |path| path.split("/").size }.reverse
        @_base_directory ||= directories.find { |dir| file_path.to_s.start_with?(dir) }
      end
    end
  end
end
