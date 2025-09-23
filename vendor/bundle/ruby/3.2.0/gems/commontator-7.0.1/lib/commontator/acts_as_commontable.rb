require_relative 'commontable_config'
require_relative 'build_thread'

module Commontator::ActsAsCommontable
  def self.included(base)
    base.class_attribute :is_commontable
    base.is_commontable = false
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_commontable(options = {})
      class_exec do
        association_options = options.extract!(:dependent)
        association_options[:dependent] ||= :nullify

        cattr_accessor :commontable_config
        self.commontable_config = Commontator::CommontableConfig.new(options)

        has_one :commontator_thread, **association_options.merge(
          as: :commontable, class_name: 'Commontator::Thread'
        )

        prepend Commontator::BuildThread

        # Support creating acts_as_commontable records without a commontator_thread when migrating
        validates :commontator_thread, presence: true, if: -> { Commontator::Thread.table_exists? }

        self.is_commontable = true
      end
    end

    alias_method :acts_as_commentable, :acts_as_commontable
  end
end

ActiveSupport.on_load :active_record do
  include Commontator::ActsAsCommontable
end
