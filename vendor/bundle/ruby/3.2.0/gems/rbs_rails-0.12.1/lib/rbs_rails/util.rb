module RbsRails
  module Util
    MODULE_NAME = Module.instance_method(:name)

    extend self

    def module_name(mod, abs: true)
      name = MODULE_NAME.bind_call(mod)
      name ="::#{name}" if abs
      name
    end

    def format_rbs(rbs)
      decls =
        if Gem::Version.new('3') <= Gem::Version.new(RBS::VERSION) 
          parsed = _ = RBS::Parser.parse_signature(rbs)
          parsed[1] + parsed[2]
        else
          # TODO: Remove this type annotation when rbs_rails drops support of RBS 2.x.
          # @type var parsed: [RBS::Declarations::t]
          parsed = _ = RBS::Parser.parse_signature(rbs)
        end

      StringIO.new.tap do |io|
        RBS::Writer.new(out: io).write(decls)
      end.string
    end
  end
end
