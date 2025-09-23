#!ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rbs', '1.0.0'
end

require 'rbs'

def args(n)
  (:T..).take(n)
end

def env
  @env ||= begin
    loader = RBS::EnvironmentLoader.new()
    loader.add(library: 'tsort')
    RBS::Environment.from_loader(loader).resolve_type_names
  end
end

def apply_to_superclass(decl)
  return unless decl.super_class

  name = decl.super_class.name
  type = env.class_decls[name] || env.class_decls[name.absolute!]
  return unless type
  return if type.type_params.empty?

  args = args(type.type_params.size)
  decl.super_class.instance_variable_set(:@args, args)
  type_params = RBS::AST::Declarations::ModuleTypeParams.new.tap do |tp|
    args.each do |a|
      tp.add RBS::AST::Declarations::ModuleTypeParams::TypeParam.new(name: a)
    end
  end

  decl.instance_variable_set(:@type_params, type_params)
end

def apply_to_itself(decl)
  name = decl.name
  type = env.class_decls[name] || env.class_decls[name.absolute!]
  return unless type
  return if type.type_params.empty?

  decl.instance_variable_set(:@type_params, type.type_params.dup)
end

def apply_to_includes(decl)
  decl.members.each do |member|
    next unless member.is_a?(RBS::AST::Members::Mixin)

    name = member.name
    type = env.class_decls[name] || env.class_decls[name.absolute!]
    next unless type
    next if type.type_params.empty?

    args = type.type_params.size.times.map { :untyped }
    member.instance_variable_set(:@args, args)
  end
end

def analyze(decls)
  decls.each do |decl|
    case decl
    when RBS::AST::Declarations::Class
      apply_to_itself(decl)
      apply_to_superclass(decl)
      apply_to_includes(decl)
      analyze(decl.members)
    when RBS::AST::Declarations::Module, RBS::AST::Declarations::Interface
      apply_to_itself(decl)
      apply_to_includes(decl)
      analyze(decl.members)
    end
  end
end

rbs = ARGF.read
decls = RBS::Parser.parse_signature(rbs)
analyze(decls)

puts RBS::Writer.new(out: $stdout).write(decls)
