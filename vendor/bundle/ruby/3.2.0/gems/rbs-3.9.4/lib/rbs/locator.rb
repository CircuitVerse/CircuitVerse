# frozen_string_literal: true

module RBS
  class Locator
    attr_reader :decls, :dirs, :buffer

    def initialize(buffer:, dirs:, decls:)
      @buffer = buffer
      @dirs = dirs
      @decls = decls
    end

    def find(line:, column:)
      pos = buffer.loc_to_pos([line, column])

      dirs.each do |dir|
        array = [] #: Array[component]
        find_in_directive(pos, dir, array) and return array
      end

      decls.each do |decl|
        array = [] #: Array[component]
        find_in_decl(pos, decl: decl, array: array) and return array
      end

      []
    end

    def find2(line:, column:)
      path = find(line: line, column: column)

      return if path.empty?

      hd, *tl = path
      if hd.is_a?(Symbol)
        [hd, tl]
      else
        [nil, path]
      end
    end

    def find_in_directive(pos, dir, array)
      return false unless dir.is_a?(AST::Directives::Use)

      if test_loc(pos, location: dir.location)
        array.unshift(dir)

        dir.clauses.each do |clause|
          if test_loc(pos, location: clause.location)
            array.unshift(clause)
            find_in_loc(pos, location: clause.location, array: array)
            return true
          end
        end
      end

      false
    end

    def find_in_decl(pos, decl:, array:)
      if test_loc(pos, location: decl.location)
        array.unshift(decl)

        case decl
        when AST::Declarations::Class
          decl.type_params.each do |param|
            find_in_type_param(pos, type_param: param, array: array) and return true
          end

          if super_class = decl.super_class
            if test_loc(pos, location: super_class.location)
              array.unshift(super_class)
              find_in_loc(pos, array: array, location: super_class.location)
              return true
            end
          end

          decl.each_decl do |decl_|
            find_in_decl(pos, decl: decl_, array: array) and return true
          end

          decl.each_member do |member|
            find_in_member(pos, array: array, member: member) and return true
          end

        when AST::Declarations::Module
          decl.type_params.each do |param|
            find_in_type_param(pos, type_param: param, array: array) and return true
          end

          decl.self_types.each do |self_type|
            if test_loc(pos, location: self_type.location)
              array.unshift(self_type)
              find_in_loc(pos, array: array, location: self_type.location)
              return true
            end
          end

          decl.each_decl do |decl_|
            find_in_decl(pos, decl: decl_, array: array) and return true
          end

          decl.each_member do |member|
            find_in_member(pos, array: array, member: member) and return true
          end

        when AST::Declarations::Interface
          decl.type_params.each do |param|
            find_in_type_param(pos, type_param: param, array: array) and return true
          end

          decl.members.each do |member|
            find_in_member(pos, array: array, member: member) and return true
          end

        when AST::Declarations::Constant, AST::Declarations::Global
          find_in_type(pos, array: array, type: decl.type) and return true

        when AST::Declarations::TypeAlias
          find_in_type(pos, array: array, type: decl.type) and return true
        end

        find_in_loc(pos, location: decl.location, array: array)

        true
      else
        false
      end
    end

    def find_in_member(pos, member:, array:)
      if test_loc(pos, location: member.location)
        array.unshift(member)

        case member
        when AST::Members::MethodDefinition
          member.overloads.each do |overload|
            find_in_method_type(pos, array: array, method_type: overload.method_type) and return true
          end
        when AST::Members::InstanceVariable, AST::Members::ClassInstanceVariable, AST::Members::ClassVariable
          find_in_type(pos, array: array, type: member.type) and return true
        when AST::Members::AttrReader, AST::Members::AttrWriter, AST::Members::AttrAccessor
          find_in_type(pos, array: array, type: member.type) and return true
        end

        find_in_loc(pos, location: member.location, array: array)

        true
      else
        false
      end
    end

    def find_in_method_type(pos, method_type:, array:)
      if test_loc(pos, location: method_type.location)
        array.unshift(method_type)

        method_type.type_params.each do |param|
          find_in_type_param(pos, type_param: param, array: array) and return true
        end

        method_type.each_type do |type|
          find_in_type(pos, array: array, type: type) and break
        end

        true
      else
        false
      end
    end

    def find_in_type_param(pos, type_param:, array:)
      if test_loc(pos, location: type_param.location)
        array.unshift(type_param)

        if upper_bound = type_param.upper_bound_type
          find_in_type(pos, type: upper_bound, array: array) and return true
        end

        if default_type = type_param.default_type
          find_in_type(pos, type: default_type, array: array) and return true
        end

        find_in_loc(pos, location: type_param.location, array: array)

        true
      else
        false
      end
    end

    def find_in_type(pos, type:, array:)
      if test_loc(pos, location: type.location)
        array.unshift(type)

        type.each_type do |type_|
          find_in_type(pos, array: array, type: type_) and return true
        end

        find_in_loc(pos, array: array, location: type.location)

        true
      else
        false
      end
    end

    def find_in_loc(pos, location:, array:)
      if test_loc(pos, location: location)
        if location.is_a?(Location)
          location.each_optional_key do |key|
            if loc = location[key]
              if loc.range === pos
                array.unshift(key)
                return true
              end
            end
          end

          location.each_required_key do |key|
            loc = location[key] or raise
            if loc.range === pos
              array.unshift(key)
              return true
            end
          end
        end

        true
      else
        false
      end
    end

    def test_loc(pos, location:)
      if location
        location.range === pos
      else
        false
      end
    end
  end
end
