# frozen_string_literal: true

class I18nSupport
  # @return [Array<Array<String>>] an array of arrays, each containing a locale name and its code
  def self.locale_names
    [
      %w[Arabic ar],
      %w[Bengali bn],
      %w[German de],
      %w[English en],
      %w[Spanish es],
      %w[French fr],
      %w[Hindi hi],
      %w[Japanese ja],
      %w[Malayalam ml],
      %w[Marathi mr],
      %w[Nepali ne]
    ]
  end
end
