require "active_support/evented_file_update_checker"

module Lookbook
  require "listen" unless Engine.runtime_context.rails_newer_than?("6.1.0")

  class EventedFileUpdateChecker < ActiveSupport::EventedFileUpdateChecker
    if Engine.runtime_context.rails_newer_than?("6.1.0")

      def initialize(files, dirs = {}, &block)
        super
        @core = Core.new(files, dirs)
      end

      class Core < ActiveSupport::EventedFileUpdateChecker::Core
        def changed(modified, added, removed)
          super
          Engine.files_changed(modified, added, removed) if @updated
        end

        # Patched to handle regex-style
        # extension matchers like `.html.*`
        def watching?(file)
          return true if super

          file = Pathname(file)
          name_parts = file.basename.to_s.split(".")
          ext = "." + name_parts.drop(1).join(".").to_s

          file.dirname.ascend do |dir|
            matching = @dirs.fetch(dir, []).map { |m| Regexp.new(m) }
            if matching.empty? || matching.find { |m| m.match?(ext) }
              break true
            elsif dir == @common_path || dir.root?
              break false
            end
          end
        end
      end

    else

      # Patched to handle regex-style
      # extension matchers like `.html.*`
      def watching?(file)
        return true if super

        file = Pathname(file)
        name_parts = file.basename.to_s.split(".")
        ext = "." + name_parts.drop(1).join(".").to_s

        file.dirname.ascend do |dir|
          matching = @dirs.fetch(dir, []).map { |m| Regexp.new(m) }
          if matching.empty? || matching.find { |m| m.match?(ext) }
            break true
          elsif dir == @lcsp || dir.root?
            break false
          end
        end
      end

      private

      def changed(modified, added, removed)
        super
        Engine.files_changed(modified, added, removed) if updated?
      end
    end
  end
end
