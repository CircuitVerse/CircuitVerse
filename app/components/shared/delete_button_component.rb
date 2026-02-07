# frozen_string_literal: true

module Shared
  class DeleteButtonComponent < ViewComponent::Base
    include ViewComponent::SlotableV2

    # Default options for the delete button
    DEFAULT_OPTIONS = {
      variant: :primary,        # :primary, :secondary
      size: :medium,           # :small, :medium, :large
      icon: nil,               # icon name or nil
      text: "Delete",          # button text
      confirm: nil,            # confirmation message
      method: :delete,         # HTTP method
      data: {},                # additional data attributes
      classes: [],             # additional CSS classes
      disabled: false          # disabled state
    }.freeze

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @variant = @options[:variant]
      @size = @options[:size]
      @icon = @options[:icon]
      @text = @options[:text]
      @confirm = @options[:confirm]
      @method = @options[:method]
      @data = @options[:data]
      @classes = @options[:classes]
      @disabled = @options[:disabled]
    end

    def call
      if @options[:href].present?
        link_to_button
      else
        button_tag
      end
    end

    private

    def link_to_button
      link_to @options[:href], 
              method: @method,
              data: link_data,
              class: button_classes,
              disabled: @disabled do
        button_content
      end
    end

    def button_tag
      button_tag button_content,
                  type: "button",
                  data: button_data,
                  class: button_classes,
                  disabled: @disabled
    end

    def button_content
      content = []
      
      # Add icon if present
      if @icon.present?
        content << image_tag("svgs/#{@icon}.svg", alt: @text, class: "me-1")
      end
      
      # Add text
      content << content_tag(:span, @text)
      
      safe_join(content)
    end

    def button_classes
      base_classes = ["btn"]
      
      # Variant classes
      base_classes << case @variant
                     when :primary
                       "primary-delete-button"
                     when :secondary
                       "secondary-button"
                     else
                       "btn-primary"
                     end

      # Size classes
      base_classes << case @size
                     when :small
                       "btn-sm"
                     when :large
                       "btn-lg"
                     end

      # Additional classes
      base_classes += Array(@classes)
      
      base_classes.join(" ")
    end

    def link_data
      data_hash = @data.dup
      
      # Add confirmation if present
      if @confirm.present?
        data_hash[:confirm] = @confirm
      end
      
      # Add modal target if present
      if @options[:modal_target].present?
        data_hash[:bs_toggle] = "modal"
        data_hash[:bs_target] = @options[:modal_target]
      end
      
      data_hash
    end

    def button_data
      data_hash = @data.dup
      
      # Add confirmation if present
      if @confirm.present?
        data_hash[:confirm] = @confirm
      end
      
      # Add modal target if present
      if @options[:modal_target].present?
        data_hash[:bs_toggle] = "modal"
        data_hash[:bs_target] = @options[:modal_target]
      end
      
      data_hash
    end
  end
end
