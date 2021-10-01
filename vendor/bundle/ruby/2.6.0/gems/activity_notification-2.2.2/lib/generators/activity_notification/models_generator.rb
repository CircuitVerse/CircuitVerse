require 'rails/generators/base'

module ActivityNotification
  module Generators
    # Notification generator to create customizable notification model from templates.
    # @example Run notification generator to create customizable notification model
    #   rails generate activity_notification:models users
    class ModelsGenerator < Rails::Generators::Base
      MODELS = ['notification', 'subscription'].freeze

      desc <<-DESC.strip_heredoc
        Create inherited ActivityNotification models in your app/models folder.

        Use -m to specify which model you want to overwrite.
        If you do no specify a model, all models will be created.
        For example:

          rails generate activity_notification:models users -m notification

        This will create a model class at app/models/users/notification.rb like this:

          class Users::Notification < ActivityNotification::Notification
            content...
          end
      DESC

      source_root File.expand_path("../../templates/models", __FILE__)
      argument :target, required: true,
        desc: "The target to create models in, e.g. users, admins"
      class_option :models, aliases: "-m", type: :array,
        desc: "Select specific models to generate (#{MODELS.join(', ')})"
      class_option :names, aliases: "-n", type: :array,
        desc: "Select model names to generate (#{MODELS.join(', ')})"

      # Create notification model in application directory
      def create_models
        @target_prefix = target.blank? ? '' : (target.camelize + '::')
        models      = options[:models] || MODELS
        model_names = options[:names]  || MODELS
        models.zip(model_names).each do |original_name, new_name|
          @model_name = new_name.camelize
          template "#{original_name}.rb",
                   "app/models/#{target}/#{@model_name.underscore}.rb"
        end
      end

      # Shows readme to console
      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
