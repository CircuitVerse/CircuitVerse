module Lookbook
  class Filter::Component < Lookbook::BaseComponent
    def initialize(store: nil, placeholder: "Type to filter&hellip;", **html_attrs)
      @model = store.nil? ? "{}" : "#{store}.raw"
      @placeholder = placeholder
      super(alpine_data: store, **html_attrs)
    end

    protected

    def alpine_component
      "filterComponent"
    end
  end
end
