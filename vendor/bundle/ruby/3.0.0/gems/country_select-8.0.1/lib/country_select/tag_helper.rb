module CountrySelect
  class CountryNotFoundError < StandardError;end
  module TagHelper
    def country_option_tags
      # In Rails 5.2+, `value` accepts no arguments and must also be called
      # with parens to avoid the local variable of the same name
      # https://github.com/rails/rails/pull/29791
      selected_option = @options.fetch(:selected) do
        if self.method(:value).arity == 0
          value()
        else
          value(@object)
        end
      end

      option_tags_options = {
        :selected => selected_option,
        :disabled => @options[:disabled]
      }

      if priority_countries.present?
        priority_countries_options = country_options_for(priority_countries, @options.fetch(:sort_provided, ::CountrySelect::DEFAULTS[:sort_provided]))

        option_tags = options_for_select(priority_countries_options, option_tags_options)
        option_tags += html_safe_newline + options_for_select([priority_countries_divider], disabled: priority_countries_divider)

        option_tags_options[:selected] = [option_tags_options[:selected]] unless option_tags_options[:selected].kind_of?(Array)
        option_tags_options[:selected].delete_if{|selected| priority_countries_options.map(&:second).include?(selected)}

        option_tags += html_safe_newline + options_for_select(country_options, option_tags_options)
      else
        option_tags = options_for_select(country_options, option_tags_options)
      end
    end

    private
    def locale
      @options.fetch(:locale, ::CountrySelect::DEFAULTS[:locale])
    end

    def priority_countries
      @options.fetch(:priority_countries, ::CountrySelect::DEFAULTS[:priority_countries])
    end

    def priority_countries_divider
      @options.fetch(:priority_countries_divider, ::CountrySelect::DEFAULTS[:priority_countries_divider])
    end

    def only_country_codes
      @options.fetch(:only, ::CountrySelect::DEFAULTS[:only])
    end

    def except_country_codes
      @options.fetch(:except, ::CountrySelect::DEFAULTS[:except])
    end

    def format
      @options.fetch(:format, ::CountrySelect::DEFAULTS[:format])
    end

    def country_options
      if only_country_codes.present?
        codes = only_country_codes & ISO3166::Country.codes
        sort = @options.fetch(:sort_provided, ::CountrySelect::DEFAULTS[:sort_provided])
      elsif except_country_codes.present?
        codes = ISO3166::Country.codes - except_country_codes
        sort = true
      else
        codes = ISO3166::Country.codes
        sort = true
      end

      country_options_for(codes, sort)
    end

    def country_options_for(country_codes, sorted=true)
      I18n.with_locale(locale) do
        country_list = country_codes.map do |code_or_name|
          if country = ISO3166::Country.new(code_or_name)
            code = country.alpha2
          elsif country = ISO3166::Country.find_country_by_any_name(code_or_name)
            code = country.alpha2
          end

          unless country.present?
            msg = "Could not find Country with string '#{code_or_name}'"
            raise CountryNotFoundError.new(msg)
          end

          formatted_country = ::CountrySelect::FORMATS[format].call(country)

          if formatted_country.is_a?(Array)
            formatted_country
          else
            [formatted_country, code]
          end

        end

        if sorted
          country_list.sort_by { |name, code| [I18n.transliterate(name), name] }
        else
          country_list
        end
      end
    end

    def html_safe_newline
      "\n".html_safe
    end
  end
end
