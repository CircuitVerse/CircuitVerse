module Lookbook
  class FileWatcher
    class << self
      def new(...)
        file_watcher.new(...)
      end

      def evented?
        !(file_watcher <= ActiveSupport::FileUpdateChecker)
      end

      protected

      def file_watcher
        @_file_watcher ||= begin
          require_relative "support/evented_file_update_checker"

          EventedFileUpdateChecker
        rescue LoadError
          ActiveSupport::FileUpdateChecker
        end
      end
    end
  end
end
