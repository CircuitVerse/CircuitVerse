require_relative 'commontator_config'

module Commontator::ActsAsCommontator
  def self.included(base)
    base.class_attribute :is_commontator
    base.is_commontator = false
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_commontator(options = {})
      class_exec do
        association_options = options.extract!(:dependent)
        association_options[:dependent] ||= :destroy

        cattr_accessor :commontator_config
        self.commontator_config = Commontator::CommontatorConfig.new(options)

        has_many :commontator_comments, **association_options.merge(
          as: :creator, class_name: 'Commontator::Comment'
        )
        has_many :commontator_subscriptions, **association_options.merge(
          as: :subscriber, class_name: 'Commontator::Subscription'
        )

        self.is_commontator = true
      end
    end

    alias_method :acts_as_commonter, :acts_as_commontator
    alias_method :acts_as_commentator, :acts_as_commontator
    alias_method :acts_as_commenter, :acts_as_commontator
  end
end

ActiveSupport.on_load :active_record do
  include Commontator::ActsAsCommontator
end
