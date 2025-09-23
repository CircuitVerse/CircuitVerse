require "active_support"

module Lookbook
  class Reloaders
    attr_reader :reloaders

    def initialize
      @reloaders = []
    end

    def add(name, directories, extensions, &callback)
      reloader = Reloader.new(name, directories, extensions, &callback)
      reloaders.push(reloader)

      if Engine.reloading?
        Rails.application.reloaders << reloader
        Rails.application.reloader.to_run { reloader.execute_if_updated }
      end

      reloader
    end

    def execute(name = nil)
      reloaders.each do |reloader|
        reloader.execute if name.nil? || name == reloader.name
      end
    end

    def register_changes(changes)
      reloader = reloaders.find { |reloader| reloader.watching?(changes) }
      reloader.last_changes = changes if reloader
    end

    class Reloader
      delegate :execute, :execute_if_updated, :updated?, to: :file_watcher

      attr_reader :name, :directories, :extensions, :callback
      attr_accessor :last_changes

      def initialize(name, directories, extensions, &callback)
        @name = name.to_sym
        @directories = directories
        @extensions = extensions
        @callback = callback
        @last_changes = nil
      end

      def watching?(changes)
        file_paths = changes.to_h.values.flatten
        !!file_paths.find do |file_path|
          file_path = Pathname(file_path).expand_path
          directories.find do |dir_path|
            matcher = File.expand_path(File.join(dir_path, "**"))
            file_path.fnmatch?(matcher)
          end
        end
      end

      protected

      def file_watcher
        return @_file_watcher if @_file_watcher

        to_watch = directories.each_with_object({}) do |directory, result|
          result[directory] = extensions
        end

        @_file_watcher ||= FileWatcher.new([], to_watch) do
          callback.call(@last_changes)
          @last_changes = nil
        end
      end
    end
  end
end
