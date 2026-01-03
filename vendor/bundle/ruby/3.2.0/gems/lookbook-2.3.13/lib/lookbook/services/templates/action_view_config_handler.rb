module Lookbook
  class ActionViewConfigHandler < Service
    attr_reader :disable_annotations, :disable_partial_prefixes

    def initialize(disable_annotations: true, disable_partial_prefixes: true)
      @disable_annotations = disable_annotations
      @disable_partial_prefixes = disable_partial_prefixes
    end

    def call
      handle_annotations
      handle_partial_prefixes

      yield
    ensure
      restore_annotations
      restore_partial_prefixes
    end

    private

    def handle_annotations
      return unless disable_annotations && ActionView::Base.respond_to?(:annotate_rendered_view_with_filenames)

      @original_annotations_value = ActionView::Base.annotate_rendered_view_with_filenames
      ActionView::Base.annotate_rendered_view_with_filenames = false
    end

    def restore_annotations
      return if @original_annotations_value.nil?

      ActionView::Base.annotate_rendered_view_with_filenames = @original_annotations_value
      @original_annotations_value = nil
    end

    def handle_partial_prefixes
      return unless disable_partial_prefixes && ActionView::Base.respond_to?(:prefix_partial_path_with_controller_namespace)

      @original_partial_prefix_value = ActionView::Base.prefix_partial_path_with_controller_namespace
      ActionView::Base.prefix_partial_path_with_controller_namespace = false
    end

    def restore_partial_prefixes
      return if @original_partial_prefix_value.nil?

      ActionView::Base.prefix_partial_path_with_controller_namespace = @original_partial_prefix_value
      @original_partial_prefix_value = nil
    end
  end
end
