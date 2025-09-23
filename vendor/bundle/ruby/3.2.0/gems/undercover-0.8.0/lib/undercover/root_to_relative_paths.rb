# frozen_string_literal: true

module Undercover
  module RootToRelativePaths
    # Needed if undercover is running inside nested subdirectories (e.g. in a monorepo app), where
    # the git paths are rooted deeper than the paths in the coverage report.
    # If that is the case, trim the git filepath to match the local relative path, assumming undercover is
    # running in the correct directory (has to be equal to SimpleCov.root for paths to match)
    # @param filepath[String]
    # @return String
    def fix_relative_filepath(filepath)
      return filepath unless @code_dir

      code_dir_abs = File.expand_path(@code_dir)

      if Pathname.new(Dir.pwd).ascend.any? { |p| p.to_s == code_dir_abs }
        prefix_to_skip = Pathname.new(Dir.pwd).relative_path_from(code_dir_abs).to_s
        return filepath.delete_prefix(prefix_to_skip).gsub(/\A\//, '')
      end

      filepath
    end
  end
end
