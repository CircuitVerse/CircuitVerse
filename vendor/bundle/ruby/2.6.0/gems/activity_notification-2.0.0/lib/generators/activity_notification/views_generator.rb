require 'rails/generators/base'

module ActivityNotification
  module Generators
    # View generator to copy customizable view files to rails application.
    # Include this module in your generator to generate ActivityNotification views.
    # `copy_views` is the main method and by default copies all views of ActivityNotification.
    # @example Run view generator to create customizable default views for all targets
    #   rails generate activity_notification:views
    # @example Run view generator to create views for users as the specified target
    #   rails generate activity_notification:views users
    # @example Run view generator to create only notification views
    #   rails generate activity_notification:views -v notifications
    # @example Run view generator to create only notification email views
    #   rails generate activity_notification:views -v mailer
    class ViewsGenerator < Rails::Generators::Base
      VIEWS = [:notifications, :mailer, :subscriptions, :optional_targets].freeze

      source_root File.expand_path("../../../../app/views/activity_notification", __FILE__)
      desc "Copies default ActivityNotification views to your application."

      argument :target, required: false, default: nil,
        desc: "The target to copy views to"
      class_option :views, aliases: "-v", type: :array,
        desc: "Select specific view directories to generate (notifications, mailer, subscriptions, optional_targets)"
      public_task :copy_views

      # Copies view files in application directory
      def copy_views
        target_views = options[:views] || VIEWS
        target_views.each do |directory|
          view_directory directory.to_sym
        end
      end

      protected

        # Copies view files to target directory
        # @api protected
        # @param [String] name             Set name of views (notifications or mailer)
        # @param [String] view_target_path Target path to create views
        def view_directory(name, view_target_path = nil)
          directory "#{name}/default", view_target_path || "#{target_path}/#{name}/#{plural_target || :default}"
        end
  
        # Gets target_path from an argument or default value
        # @api protected
        # @return [String] target_path from an argument or default value
        def target_path
          @target_path ||= "app/views/activity_notification"
        end
  
        # Gets plural_target from target argument or default value
        # @api protected
        # @return [String] target_path from target argument or default value
        def plural_target
          @plural_target ||= target.presence && target.to_s.underscore.pluralize
        end
    end

  end
end
