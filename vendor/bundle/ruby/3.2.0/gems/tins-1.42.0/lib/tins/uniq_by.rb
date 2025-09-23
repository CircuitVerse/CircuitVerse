require 'tins/string_version'

module Tins
  module UniqBy
    if Tins::StringVersion.compare(RUBY_VERSION, :<=, "1.8")
      def uniq_by(&block)
        block ||= lambda { |x| x }
        inject({}) { |h, e| h[ block.call(e) ] ||= e; h }.values
      end
    else
      require 'tins/deprecate'
      extend Tins::Deprecate

      deprecate method:
        def uniq_by(&block)
          uniq(&block)
        end,
        new_method: :uniq
    end
  end
end

require 'tins/alias'
