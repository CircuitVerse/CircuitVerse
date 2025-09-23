require 'json'

module Playwright
  module LocatorUtils
    def get_by_test_id(test_id)
      test_id_attribute_name = ::Playwright::LocatorUtils.instance_variable_get(:@test_id_attribute_name)
      locator(get_by_test_id_selector(test_id_attribute_name, test_id))
    end

    def get_by_alt_text(text, exact: false)
      locator(get_by_alt_text_selector(text, exact: exact))
    end

    def get_by_label(text, exact: false)
      locator(get_by_label_selector(text, exact: exact))
    end

    def get_by_placeholder(text, exact: false)
      locator(get_by_placeholder_selector(text, exact: exact))
    end

    def get_by_text(text, exact: false)
      locator(get_by_text_selector(text, exact: exact))
    end

    def get_by_title(text, exact: false)
      locator(get_by_title_selector(text, exact: exact))
    end

    def get_by_role(role, **options)
      locator(get_by_role_selector(role, **(options.compact)))
    end

    # set from Playwright::Selectors#test_id_attribute=
    @test_id_attribute_name = 'data-testid'

    private def get_by_attribute_text_selector(attr_name, text, exact: false)
      "internal:attr=[#{attr_name}=#{escape_for_attribute_selector_or_regex(text, exact)}]"
    end

    private def get_by_test_id_selector(test_id_attribute_name, test_id)
      "internal:testid=[#{test_id_attribute_name}=#{escape_for_attribute_selector_or_regex(test_id, true)}]"
    end

    private def get_by_label_selector(text, exact:)
      "internal:label=#{escape_for_text_selector(text, exact)}"
    end

    private def get_by_alt_text_selector(text, exact:)
      get_by_attribute_text_selector('alt', text, exact: exact)
    end

    private def get_by_title_selector(text, exact:)
      get_by_attribute_text_selector('title', text, exact: exact)
    end

    private def get_by_placeholder_selector(text, exact:)
      get_by_attribute_text_selector('placeholder', text, exact: exact)
    end

    private def get_by_text_selector(text, exact:)
      "internal:text=#{escape_for_text_selector(text, exact)}"
    end

    private def get_by_role_selector(role, **options)
      props = []

      ex = {
        includeHidden: -> (value) { ['include-hidden', value.to_s] },
        name: -> (value) { ['name', escape_for_attribute_selector_or_regex(value, options[:exact])]},
      }

      %i[
        checked
        disabled
        selected
        expanded
        includeHidden
        level
        name
        pressed
      ].each do |attr_name|
        if options.key?(attr_name)
          attr_value = options[attr_name]
          props << (ex[attr_name]&.call(attr_value) || [attr_name, attr_value.to_s])
        end
      end

      opts = props.map { |k, v| "[#{k}=#{v}]"}.join('')
      "internal:role=#{role}#{opts}"
    end

    # @param text [String]
    private def escape_for_regex(text)
      text.gsub(/[.*+?^>${}()|\[\]\\]/) { "\\#{$&}" }
    end

    # @param text [Regexp|String]
    private def escape_for_text_selector(text, exact)
      if text.is_a?(Regexp)
        regex = JavaScript::Regex.new(text)
        return "/#{regex.source}/#{regex.flag}"
      end

      if exact
        "#{text.to_json}s"
      else
        "#{text.to_json}i"
      end
    end

    # @param text [Regexp|String]
    private def escape_for_attribute_selector_or_regex(text, exact)
      if text.is_a?(Regexp)
        regex = JavaScript::Regex.new(text)
        "/#{regex.source}/#{regex.flag}"
      else
        escape_for_attribute_selector(text, exact)
      end
    end

    # @param text [String]
    private def escape_for_attribute_selector(text, exact)
      # TODO: this should actually be
      # cssEscape(value).replace(/\\ /g, ' ')
      # However, our attribute selectors do not conform to CSS parsing spec,
      # so we escape them differently.
      _text = text.gsub(/\\/) { "\\\\" }.gsub(/["]/, '\\"')
      if exact
        "\"#{_text}\""
      else
        "\"#{_text}\"i"
      end
    end
  end
end
