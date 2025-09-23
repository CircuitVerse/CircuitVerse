module Lookbook
  module Where
    class << self
      attr_accessor :editor

      def is_proc(proc)
        source_location(proc)
      end

      def is_method(klass, method_name)
        source_location(klass.method(method_name))
      end

      def is_instance_method(klass, method_name)
        source_location(klass.instance_method(method_name))
      end

      def is_class(klass)
        methods = defined_methods(klass)
        file_groups = methods.group_by { |sl| sl[0] }
        file_counts = file_groups.map do |file, sls|
          lines = sls.map { |sl| sl[1] }
          count = lines.size
          line = lines.min
          {file: file, count: count, line: line}
        end
        file_counts.sort_by! { |fc| fc[:count] }
        file_counts.map { |fc| [fc[:file], fc[:line]] }
      end

      private

      def source_location(method)
        method.source_location || (
          method.to_s =~ /: (.*)>/
          $1
        )
      end

      def defined_methods(klass)
        methods = klass.methods(false).map { |m| klass.method(m) } +
          klass.instance_methods(false).map { |m| klass.instance_method(m) }
        methods.map!(&:source_location)
        methods.compact!
        methods
      end
    end
  end
end
