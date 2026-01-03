module RbsRails
  class DependencyBuilder
    attr_reader :deps, :done

    def initialize
      @deps = []
      @done = Set.new(['ActiveRecord::Base', 'ActiveRecord', 'Object'])
    end

    def build
      dep_rbs = +""
      deps.uniq!
      while dep = shift
        next unless done.add?(dep)

        case dep_object = Object.const_get(dep)
        when Class
          superclass = dep_object.superclass or raise
          super_name = Util.module_name(superclass)
          deps << super_name
          dep_rbs << "class #{dep} < #{super_name} end\n"
        when Module
          dep_rbs << "module #{dep} end\n"
        else
          raise
        end

        # push namespaces
        namespaces = dep.split('::')
        namespaces.pop
        namespaces.inject('') do |base, name|
          full_name = base.empty? ? name : [base, name].join('::')
          deps << full_name
          full_name
        end
      end

      unless dep_rbs.empty?
        Util.format_rbs(dep_rbs)
      end
    end

    private def shift
      deps.shift&.sub(/^::/, '')
    end
  end
end
