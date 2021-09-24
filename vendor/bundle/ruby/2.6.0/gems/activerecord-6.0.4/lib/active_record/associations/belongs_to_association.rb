# frozen_string_literal: true

module ActiveRecord
  module Associations
    # = Active Record Belongs To Association
    class BelongsToAssociation < SingularAssociation #:nodoc:
      def handle_dependency
        return unless load_target

        case options[:dependent]
        when :destroy
          target.destroy
          raise ActiveRecord::Rollback unless target.destroyed?
        else
          target.send(options[:dependent])
        end
      end

      def inversed_from(record)
        replace_keys(record)
        super
      end

      def default(&block)
        writer(owner.instance_exec(&block)) if reader.nil?
      end

      def reset
        super
        @updated = false
      end

      def updated?
        @updated
      end

      def decrement_counters
        update_counters(-1)
      end

      def increment_counters
        update_counters(1)
      end

      def decrement_counters_before_last_save
        if reflection.polymorphic?
          model_was = owner.attribute_before_last_save(reflection.foreign_type).try(:constantize)
        else
          model_was = klass
        end

        foreign_key_was = owner.attribute_before_last_save(reflection.foreign_key)

        if foreign_key_was && model_was < ActiveRecord::Base
          update_counters_via_scope(model_was, foreign_key_was, -1)
        end
      end

      def target_changed?
        owner.saved_change_to_attribute?(reflection.foreign_key)
      end

      private
        def replace(record)
          if record
            raise_on_type_mismatch!(record)
            set_inverse_instance(record)
            @updated = true
          end

          replace_keys(record)

          self.target = record
        end

        def update_counters(by)
          if require_counter_update? && foreign_key_present?
            if target && !stale_target?
              target.increment!(reflection.counter_cache_column, by, touch: reflection.options[:touch])
            else
              update_counters_via_scope(klass, owner._read_attribute(reflection.foreign_key), by)
            end
          end
        end

        def update_counters_via_scope(klass, foreign_key, by)
          scope = klass.unscoped.where!(primary_key(klass) => foreign_key)
          scope.update_counters(reflection.counter_cache_column => by, touch: reflection.options[:touch])
        end

        def find_target?
          !loaded? && foreign_key_present? && klass
        end

        def require_counter_update?
          reflection.counter_cache_column && owner.persisted?
        end

        def replace_keys(record)
          owner[reflection.foreign_key] = record ? record._read_attribute(primary_key(record.class)) : nil
        end

        def primary_key(klass)
          reflection.association_primary_key(klass)
        end

        def foreign_key_present?
          owner._read_attribute(reflection.foreign_key)
        end

        # NOTE - for now, we're only supporting inverse setting from belongs_to back onto
        # has_one associations.
        def invertible_for?(record)
          inverse = inverse_reflection_for(record)
          inverse && inverse.has_one?
        end

        def stale_state
          result = owner._read_attribute(reflection.foreign_key) { |n| owner.send(:missing_attribute, n, caller) }
          result && result.to_s
        end
    end
  end
end
