require 'commontator/commontable_config'

module Commontator
  module ActsAsCommontable
    def self.included(base)
      base.class_attribute :is_commontable
      base.is_commontable = false
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_commontable(options = {})
        class_eval do
          cattr_accessor :commontable_config
          self.commontable_config = Commontator::CommontableConfig.new(options)
          self.is_commontable = true

          has_one :thread, as: :commontable,
                           class_name: 'Commontator::Thread'

          validates_presence_of :thread

          prepend ThreadWithCommontator
        end
      end

      module ThreadWithCommontator
        def thread
          @thread ||= super
          return @thread unless @thread.nil?

          @thread = build_thread
          @thread.save if persisted?
          @thread
        end
      end

      alias_method :acts_as_commentable, :acts_as_commontable
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontable
