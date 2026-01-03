module Lookbook
  class Toolbar::Component < Lookbook::BaseComponent
    DIVIDE_CLASSES = {
      left: "border-l",
      right: "border-r"
    }

    ALIGN_CLASSES = {
      right: "ml-auto",
      left: "mr-auto",
      middle: "mx-auto"
    }

    renders_many :sections, ->(align: :nil, divide: nil, padded: false, **attrs, &block) do
      Lookbook::TagComponent.new class: [
        "min-w-0",
        {
          "px-4": padded,
          "#{DIVIDE_CLASSES[divide]}": divide.present?,
          "#{ALIGN_CLASSES[align]}": align.present?
        },
        attrs[:class]
      ], **attrs.except(:class), &block
    end
  end
end
