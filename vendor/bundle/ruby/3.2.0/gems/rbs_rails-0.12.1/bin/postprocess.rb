#!ruby

# TODO: Expose me to user

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rbs', '1.0.0'
end

require 'rbs'
require 'rbs/cli'
require 'optparse'

def env(options:)
  loader = options.loader
  RBS::Environment.from_loader(loader).resolve_type_names
end

def parse_option(argv)
  opt = OptionParser.new
  options = RBS::CLI::LibraryOptions.new
  options.setup_library_options(opt)

  return opt.parse(argv), options
end

class FileMatcher
  def initialize(targets:)
    base_dir = Dir.pwd
    @targets = targets + targets.map { |t| File.expand_path(t, base_dir) }
  end

  def match?(fname)
    @targets.any? { |t| fname.start_with?(t) }
  end
end

def class_method_name(concern)
  RBS::TypeName.new(namespace: concern.name.to_namespace, name: :ClassMethods)
end

def process(decl, env:, builder:, update_targets:)
  concerns = decl.members.select do |m|
    next false unless m.is_a?(RBS::AST::Members::Include)
    next false unless m.name.kind == :class

    mod_entry = env.class_decls[m.name]
    unless mod_entry
      warn "unknown type: #{m.name}"
      next false
    end

    a = builder.singleton_ancestors(m.name)
    a.ancestors.any? { |ancestor| ancestor.name.to_s == '::ActiveSupport::Concern' }
  end

  concerns.each do |concern|
    class_methods_name = class_method_name(concern)
    class_methods_type = env.class_decls[class_methods_name]
    next unless class_methods_type

    # Skip if the decl already extend ClassMethods
    a = builder.singleton_ancestors(decl.name)
    next if a.ancestors.any? { |ancestor| ancestor.name == class_methods_name }

    # TODO: Insert `extend class_methods_name` to decl
    update_targets << [decl, concern]
  end
end

def each_decl_descendant(decl:, path: [], &block)
  return unless decl.is_a?(RBS::AST::Declarations::Class) || decl.is_a?(RBS::AST::Declarations::Module)

  block.call(decl: decl, path: path)
  path = [*path, decl]
  decl.each_decl do |child|
    each_decl_descendant(decl: child, path: path, &block)
  end
end

def may_eql_member?(a, b)
  a.name.to_s.split('::').last == b.name.to_s.split('::').last
end

def update!(update_targets:, only:)
  update_targets.group_by { |decl, _concern| decl.location.name }.each do |fname, target_decls|
    next unless only.match?(fname)

    tree = RBS::Parser.parse_signature(File.read(fname))
    target_decls.each do |target_decl, concern|
      catch(:break) do
        tree.each do |node|
          each_decl_descendant(decl: node) do |decl:, path:|
            next unless [relative = [*path, decl].map { |p| p.name.to_s }.join('::'), '::' + relative].include?(target_decl.name.to_s)

            idx = decl.members.index { |m| may_eql_member?(m, concern) } || -1
            extend = RBS::AST::Members::Extend.new(name: class_method_name(concern), args: [], annotations: [], location: nil, comment: nil)
            decl.members.insert(idx + 1, extend)
            throw :break
          end
        end
      end
    end

    File.open(fname, 'w') do |f|
      RBS::Writer.new(out: f).write(tree)
    end
  end
end

def run(argv)
  targets, options = parse_option(argv)
  env = env(options: options)
  builder = RBS::DefinitionBuilder.new(env: env)
  matcher = FileMatcher.new(targets: targets)

  only = ENV['ONLY']&.then { Regexp.new(_1) } || //

  update_targets = []

  env.class_decls.each do |_name, entry|
    entry.decls.each do |d|
      decl = d.decl
      loc = decl.location
      fname = loc.name
      next unless matcher.match?(fname)

      process(decl, env: env, builder: builder, update_targets: update_targets)
    end
  end

  update!(update_targets: update_targets, only: only)
end

run(ARGV)
