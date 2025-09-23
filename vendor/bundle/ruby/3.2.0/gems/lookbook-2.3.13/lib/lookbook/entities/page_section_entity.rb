module Lookbook
  # Represents a documentation page section.
  #
  # @ignore methods
  # @api private
  class PageSectionEntity < PageEntity
    attr_accessor :parent

    def initialize(file_path)
      @file_path = Pathname(file_path)
      @parent = nil
      super
    end

    def name
      Utils.name(name_parts[:name])
    end

    def lookup_path
      directory = if relative_directory_path.present? && !relative_directory_path.to_s.start_with?(".")
        relative_directory_path
      end

      path = PathUtils.to_path(directory, name_parts[:parent_name])
      PathUtils.to_lookup_path(path)
    end

    def landing?
      false
    end

    def url_path
      nil
    end

    alias_method :page, :parent

    protected

    def name_parts
      return @_name_parts if @_name_parts

      matches = file_name(true).match(/(?<parent_name>.*)\[(?<name>.*)\]/)
      @_name_parts ||= {name: matches[:name], parent_name: matches[:parent_name]}
    end
  end
end
