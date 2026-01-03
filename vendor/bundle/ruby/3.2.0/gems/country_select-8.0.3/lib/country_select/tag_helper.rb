# frozen_string_literal: true

module CountrySelect
  class CountryNotFoundError < StandardError; end

  module TagHelper
    unless respond_to?(:options_for_select)
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::Tags::SelectRenderer if defined?(ActionView::Helpers::Tags::SelectRenderer)
    end

    def country_option_tags
      # In Rails 5.2+, `value` accepts no arguments and must also be called
      # with parens to avoid the local variable of the same name
      # https://github.com/rails/rails/pull/29791
      selected_option = @options.fetch(:selected) do
        if self.method(:value).arity.zero?
          value()
        else
          value(@object)
        end
      end

      option_tags_options = {
        selected: selected_option,
        disabled: @options[:disabled]
      }

      if priority_countries.present?
        options_for_select_with_priority_countries(country_options, option_tags_options)
      else
        options_for_select(country_options, option_tags_options)
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
      codes = ISO3166::Country.codes

      if only_country_codes.present?
        codes = only_country_codes & codes
        sort = @options.fetch(:sort_provided, ::CountrySelect::DEFAULTS[:sort_provided])
      else
        codes -= except_country_codes if except_country_codes.present?
        sort = true
      end

      country_options_for(codes, sorted: sort)
    end

    def country_options_for(country_codes, sorted: true)
      I18n.with_locale(locale) do
        country_list = country_codes.map { |code_or_name| get_formatted_country(code_or_name) }

        country_list.sort_by! { |name, _| [I18n.transliterate(name.to_s), name] } if sorted
        country_list
      end
    end

    def options_for_select_with_priority_countries(country_options, tags_options)
      sorted = @options.fetch(:sort_provided, ::CountrySelect::DEFAULTS[:sort_provided])
      priority_countries_options = country_options_for(priority_countries, sorted: sorted)

      option_tags = priority_options_for_select(priority_countries_options, tags_options)

      tags_options[:selected] = Array(tags_options[:selected]).delete_if do |selected|
        priority_countries_options.map(&:second).include?(selected)
      end

      option_tags += "\n".html_safe + options_for_select(country_options, tags_options)

      option_tags
    end

    def priority_options_for_select(priority_countries_options, tags_options)
      option_tags = options_for_select(priority_countries_options, tags_options)
      option_tags += "\n".html_safe +
                     options_for_select([priority_countries_divider], disabled: priority_countries_divider)
    end

    def get_formatted_country(code_or_name)
      country = ISO3166::Country.new(code_or_name) ||
                ISO3166::Country.find_country_by_any_name(code_or_name)

      raise(CountryNotFoundError, "Could not find Country with string '#{code_or_name}'") unless country.present?

      code = country.alpha2
      formatted_country = ::CountrySelect::FORMATS[format].call(country)

      if formatted_country.is_a?(Array)
        formatted_country
      else
        [formatted_country, code]
      end
    end
  end
end
