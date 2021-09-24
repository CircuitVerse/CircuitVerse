module CountrySelect
  FORMATS = {}

  FORMATS[:default] = lambda do |country|
    # Need to use :[] specifically, not :dig, because country.translations is a
    # ISO3166::Translations object, which overrides :[] to support i18n locale fallbacks
    country.translations&.send(:[], I18n.locale.to_s) || country.name
  end
end
