module Lookbook
  class EntityCollection
    include Enumerable

    delegate_missing_to :entities

    attr_reader :entities

    def initialize(entities = nil)
      @_cache = {}
      @entities = []
      add(entities)
    end

    def add(to_add = nil)
      Array(to_add).each do |entity|
        unless find_by_path(entity.lookup_path)
          @entities.push(entity)
        end
      end
      clear_cache
    end

    def find_by_id(id)
      id = Utils.id(id)
      @entities.find { |entity| entity.id == id }
    end

    def find_by_path(path)
      @entities.find { |entity| entity.lookup_path.to_s == path.to_s }
    end

    def next(entity)
      index = entities.find_index { |i| i.lookup_path == entity.lookup_path }
      entities[index + 1] unless index.nil?
    end

    def previous(entity)
      index = entities.find_index { |i| i.lookup_path == entity.lookup_path }
      entities[index - 1] if !index.nil? && index > 0
    end

    def each(&block)
      if block
        entities.sort.each { |entity| yield entity }
      else
        to_enum(:each)
      end
    end

    def flat_map(...)
      entities.map(...).map { |e| e.respond_to?(:to_a) ? e.to_a : e }.flatten
    end

    def clear_all
      @entities = []
      clear_cache
    end

    protected

    def clear_cache
      @_cache = {}
    end
  end
end
