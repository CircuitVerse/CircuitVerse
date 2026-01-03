require 'tins/string_version'
require 'tins/uniq_by'

module Tins
  module ::Enumerable
    include UniqBy
  end

  class ::Array
    if Tins::StringVersion.compare(RUBY_VERSION, :<=, "1.8")
      include UniqBy

      def uniq_by!(&b)
        replace uniq_by(&b)
      end
    else
      require 'tins/deprecate'
      extend Tins::Deprecate

      deprecate method:
        alias_method(:uniq_by!, :uniq!),
        new_method: :uniq!
    end
  end
end
