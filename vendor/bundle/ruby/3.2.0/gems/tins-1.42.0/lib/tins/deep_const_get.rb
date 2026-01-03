require 'tins/string_version'

module Tins
  module DeepConstGet
    class << self
      if ::Object.method(:const_defined?).arity == 1
        # :nocov:
        # We do not create coverage on 1.8
        def const_defined_in?(modul, constant)
          modul.const_defined?(constant)
        end
        # :nocov:
      else
        require 'tins/deprecate'
        extend Tins::Deprecate

        deprecate method:
          def const_defined_in?(modul, constant)
            modul.const_defined?(constant, false)
          end,
          new_method: :const_defined?
      end

      if Tins::StringVersion.compare(RUBY_VERSION, :<, '2.0')
        def deep_const_get(path, start_module = Object)
          path.to_s.split('::').inject(start_module) do |p, c|
            case
            when c.empty?
              if start_module == Object
                Object
              else
                raise ArgumentError, "top level constants cannot be reached from"\
                  " start module #{start_module.inspect}"
              end
            when const_defined_in?(p, c)
              p.const_get(c)
            else
              begin
                p.const_missing(c)
              rescue NameError => e
                raise ArgumentError, "can't get const #{path}: #{e}"
              end
            end
          end
        end
      else
        require 'tins/deprecate'
        extend Tins::Deprecate

        deprecate method:
          def deep_const_get(path, start_module = Object)
            start_module.const_get(path)
          rescue NameError => e
            raise ArgumentError, "can't get const #{path}: #{e}"
          end,
          new_method: :const_get
      end
    end

    def deep_const_get(path, start_module = Object)
      ::Tins::DeepConstGet.deep_const_get(path, start_module)
    end
  end
end
