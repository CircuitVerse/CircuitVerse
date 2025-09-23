module Steep
  module AST
    module Types
      class Boolean
        extend SharedInstance
        
        def ==(other)
          other.is_a?(Boolean)
        end

        def hash
          self.class.hash
        end

        alias eql? ==

        def subst(s)
          self
        end

        def to_s
          "bool"
        end

        include Helper::NoFreeVariables

        include Helper::NoChild

        def level
          [0]
        end

        def back_type
          Union.build(
            types: [
              Builtin::TrueClass.instance_type,
              Builtin::FalseClass.instance_type
            ]
          )
        end
      end
    end
  end
end

