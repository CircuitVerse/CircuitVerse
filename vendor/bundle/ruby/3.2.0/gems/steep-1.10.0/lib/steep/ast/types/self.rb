module Steep
  module AST
    module Types
      class Self
        extend SharedInstance

        def ==(other)
          other.is_a?(Self)
        end

        def hash
          self.class.hash
        end

        alias eql? ==

        def to_s
          "self"
        end

        include Helper::NoChild

        def subst(s)
          if s.self_type
            s.self_type
          else
            self
          end
        end

        @@fvs = Set[instance]

        def free_variables
          @@fvs
        end

        def level
          [0]
        end
      end
    end
  end
end
