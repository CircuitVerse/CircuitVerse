module Lookbook
  module DisplayOptions
    class Editor::Component < Lookbook::BaseComponent
      renders_many :fields, Lookbook::DisplayOptions::Field::Component
    end
  end
end
