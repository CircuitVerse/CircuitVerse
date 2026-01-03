module Lookbook
  class Theme
    BASE_THEMES = {
      indigo: {
        favicon_light_mode: "#4F46E5",
        favicon_dark_mode: "#818CF8"
      },
      zinc: {
        favicon_light_mode: "#52525b",
        favicon_dark_mode: "#E4E4E7"
      },
      blue: {
        favicon_light_mode: "#2563EB",
        favicon_dark_mode: "#60A5FA"
      },
      green: {
        favicon_light_mode: "#16a34a",
        favicon_dark_mode: "#66E093"
      },
      rose: {
        favicon_light_mode: "#E11D48",
        favicon_dark_mode: "#FFA0B5"
      }
    }

    def initialize(base_theme, overrides = {})
      @base_theme = base_theme
      @overrides = overrides
      @css = nil
    end

    def favicon_light_mode
      @overrides[:favicon_light_mode].presence ||
        @overrides[:favicon].presence ||
        BASE_THEMES[@base_theme.to_sym][:favicon_light_mode]
    end

    def favicon_dark_mode
      @overrides[:favicon_dark_mode].presence ||
        @overrides[:favicon].presence ||
        BASE_THEMES[@base_theme.to_sym][:favicon_dark_mode]
    end

    def to_css
      return @css unless @css.nil?
      @css ||= if @overrides.present?
        styles = [":root {"]
        styles << @overrides.reject { |key| key.to_s.start_with?("favicon") }.map do |key, value|
          "  --lookbook-#{key.to_s.underscore.tr("_", "-")}: #{value};"
        end
        styles.push "}"
        styles.join("\n")
      else
        ""
      end
    end

    def self.valid_theme?(name)
      BASE_THEMES.key? name.to_sym
    end
  end
end
