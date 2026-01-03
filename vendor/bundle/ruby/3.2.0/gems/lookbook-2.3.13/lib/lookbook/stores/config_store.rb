module Lookbook
  # Configuration store for Lookbook.
  #
  # Config option values can be get/set using hash property access syntax
  # or dot-notation syntax.
  #
  # @example :ruby
  #   # Lookbook config access in Rails config files:
  #   config.lookbook.ui_theme = :zinc
  #
  #   # Lookbook config access everywhere else:
  #   Lookbook.config.ui_theme = :zinc
  #
  # @ignore methods
  # @api public
  class ConfigStore
    CONFIG_FILE = "config/app.yml"
    DEFAULT_FAVICONS = {
      light: "assets/img/favicon_light.svg",
      dark: "assets/img/favicon_dark.svg"
    }

    delegate_missing_to :store
    attr_reader :store

    def initialize(config = nil)
      @store = Store.new(config, recursive: true)
    end

    def project_name
      if store[:project_name].nil?
        if store[:project_logo].nil?
          Rails.application.class.module_parent.name.titleize
        else
          false
        end
      else
        store[:project_name]
      end
    end

    def project_name=(name)
      store[:project_name] = name
    end

    def page_extensions=(extensions = nil)
      store[:page_extensions].push(*extensions.to_a).uniq!
    end

    def listen_extensions=(extensions = nil)
      store[:listen_extensions].push(*extensions.to_a).uniq!
    end

    def markdown_options=(options = nil)
      store[:markdown_options].merge!(options.to_h)
    end

    def highlighter_options=(options = nil)
      store[:highlighter_options].merge!(options.to_h)
    end

    def preview_disable_error_handling=(value)
      store[:preview_disable_error_handling] = value
    end

    def preview_single_pass_rendering=(value)
      store[:preview_single_pass_rendering] = value
    end

    def ui_theme=(name)
      name = name.to_s
      if Theme.valid_theme?(name)
        store[:ui_theme] = name
      else
        raise ConfigError.new("'#{name}' is not a valid Lookbook theme. ", scope: "app.config")
      end
    end

    def ui_favicon_light
      @_ui_favicon_light ||= get_favicon(:light)
    end

    def ui_favicon_dark
      @_ui_favicon_dark ||= get_favicon(:dark)
    end

    def ui_theme_overrides(&block)
      if block
        yield store[:ui_theme_overrides]
      else
        store[:ui_theme_overrides]
      end
    end

    def self.init_from_config(env: Rails.env)
      new(default_config(env: env))
    end

    def self.default_config(env: Rails.env)
      ConfigLoader.call(CONFIG_FILE, env: env)
    end

    private

    def get_favicon(theme)
      default_favicon_path = Engine.root.join(DEFAULT_FAVICONS[theme])
      default_favicon = FileDataUriEncoder.call(default_favicon_path)

      if ui_favicon.present?
        if ui_favicon.is_a?(Hash)
          if ui_favicon[theme].is_a?(String)
            DataUriEncoder.call(ui_favicon[theme], "image/svg+xml")
          else
            default_favicon
          end
        elsif ui_favicon.is_a?(String)
          DataUriEncoder.call(ui_favicon, "image/svg+xml")
        else
          default_favicon
        end
      end
    end
  end
end
