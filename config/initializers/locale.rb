I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
 
# Permitted locales available for the application
I18n.available_locales = [:en, :pt, :vi, :hi]
 
I18n.default_locale = :en