require 'commontator/commontator_config'

module Commontator
  module ActsAsCommontator
    def self.included(base)
      base.class_attribute :is_commontator
      base.is_commontator = false
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commontator(options = {})
        class_eval do
          cattr_accessor :commontator_config
          self.commontator_config = Commontator::CommontatorConfig.new(options)
          self.is_commontator = true

          has_many :comments,      as: :creator,
                                   class_name: 'Commontator::Comment'
          has_many :subscriptions, as: :subscriber,
                                   class_name: 'Commontator::Subscription',
                                   dependent: :destroy
        end
      end
      
      alias_method :acts_as_commonter, :acts_as_commontator
      alias_method :acts_as_commentator, :acts_as_commontator
      alias_method :acts_as_commenter, :acts_as_commontator
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontator
