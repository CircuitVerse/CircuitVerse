require 'tins/string_version'

module Tins
  module CountBy
    if Tins::StringVersion.compare(RUBY_VERSION, :<=, "1.8")
      def count_by(&block)
        block ||= lambda { |x| true }
        inject(0) { |s, e| s += 1 if block.call(e); s }
      end
    else
      require 'tins/deprecate'
      extend Tins::Deprecate

      deprecate method:
        def count_by(&block)
          count(&block)
        end,
        new_method: :count
    end
  end
end
