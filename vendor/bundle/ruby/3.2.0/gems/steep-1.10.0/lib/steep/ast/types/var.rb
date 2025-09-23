module Steep
  module AST
    module Types
      class Var
        attr_reader :name

        def initialize(name:)
          @name = name
        end

        def ==(other)
          other.is_a?(Var) &&
            other.name == name
        end

        def hash
          self.class.hash ^ name.hash
        end

        alias eql? ==

        def self.fresh_name(name)
          @mutex ||= Thread::Mutex.new

          @mutex.synchronize do
            @max ||= 0
            @max += 1

            :"#{name}(#{@max})"
          end
        end

        def self.fresh(name, location: nil)
          new(name: fresh_name(name))
        end

        def to_s
          name.to_s
        end

        def subst(s)
          if s.key?(name)
            s[name]
          else
            self
          end
        end

        def free_variables()
          @fvs ||= Set.new([name])
        end

        include Helper::NoChild

        def level
          [0]
        end

        def update(name: self.name)
          self.class.new(name: name)
        end
      end
    end
  end
end
