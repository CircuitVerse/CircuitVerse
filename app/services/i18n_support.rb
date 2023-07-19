# frozen_string_literal: true

class I18nSupport
  # @return [Array<Array<String>>] an array of arrays, each containing a locale name and its code
  def self.locale_names
    [
      %w[English en],
      %w[Hindi hi],
      %w[Bengali bn],
      %w[Marathi mr]
    ]
  end
end
