module DisposableMail
  class Railtie < ::Rails::Railtie
    initializer 'disposable_mail-i18n' do |app|
      locales = app.config.i18n.available_locales || []
      yml_pattern = locales.blank? ? '*' : "{#{locales.join(',')}}"
      I18n.load_path.concat(Dir[File.join(File.dirname(__FILE__), 'locales', "#{yml_pattern}.yml")])
    end
  end
end
