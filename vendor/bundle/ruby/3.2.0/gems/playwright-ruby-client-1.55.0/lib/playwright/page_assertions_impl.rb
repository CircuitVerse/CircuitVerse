module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/main/playwright/_impl/_assertions.py
  define_api_implementation :PageAssertionsImpl do
    def self._define_negation(method_name)
      define_method("not_#{method_name}") do |*args, **kwargs|
        if kwargs.empty? # for Ruby < 2.7
          _not.public_send(method_name, *args)
        else
          _not.public_send(method_name, *args, **kwargs)
        end
      end
    end

    def initialize(page, default_expect_timeout, is_not, message)
      @page = PlaywrightApi.unwrap(page)
      @frame = @page.main_frame
      @default_expect_timeout = default_expect_timeout
      @is_not = is_not
      @custom_message = message
    end

    private def expect_impl(expression, expect_options, expected, message, title)
      expect_options[:timeout] ||= @default_expect_timeout
      expect_options[:isNot] = @is_not
      message.gsub!("expected to", "not expected to") if @is_not
      expect_options.delete(:useInnerText) if expect_options.key?(:useInnerText) && expect_options[:useInnerText].nil?

      result = @frame.expect(nil, expression, expect_options, title)

      if result["matches"] == @is_not
        actual = result["received"]

        log =
          if result.key?("log")
            log_contents = result["log"].join("\n").strip

            "\nCall log:\n #{log_contents}"
          else
            ""
          end

        out_message =
          if @custom_message && expected
            "\nExpected value: '#{expected}'"
          elsif @custom_message
            @custom_message
          elsif message != "" && expected
            "\n#{message} '#{expected}'"
          else
            "\n#{message}"
          end

          out = "#{out_message}\nActual value #{actual} #{log}"
          raise AssertionError.new(out)
      else
        true
      end
    end

    private def _not # "not" is reserved in Ruby
      PageAssertionsImpl.new(
        @page,
        @default_expect_timeout,
        !@is_not,
        @message
      )
    end

    private def expected_regex(pattern, match_substring, normalize_white_space, ignore_case)
      regex = JavaScript::Regex.new(pattern)
      expected = {
        regexSource: regex.source,
        regexFlags: regex.flag,
        matchSubstring: match_substring,
        normalizeWhiteSpace: normalize_white_space,
        ignoreCase: ignore_case
      }
      expected.delete(:ignoreCase) if ignore_case.nil?

      expected
    end

    private def to_expected_text_values(items, match_substring: false, normalize_white_space: false, ignore_case: false)
      return [] unless items.respond_to?(:each)

      items.each.with_object([]) do |item, out|
        out <<
          if item.is_a?(String) && ignore_case
            {
              string: item,
              matchSubstring: match_substring,
              normalizeWhiteSpace: normalize_white_space,
              ignoreCase: ignore_case,
            }
          elsif item.is_a?(String)
            {
              string: item,
              matchSubstring: match_substring,
              normalizeWhiteSpace: normalize_white_space,
            }
          elsif item.is_a?(Regexp)
            expected_regex(item, match_substring, normalize_white_space, ignore_case)
          end
      end
    end

    def to_have_title(title_or_regex, timeout: nil)
      expected_text = to_expected_text_values(
        [title_or_regex],
        normalize_white_space: true,
      )

      expect_impl(
        "to.have.title",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        title_or_regex,
        "Page title expected to be",
        'Expect "to_have_title"',
      )
    end
    _define_negation :to_have_title

    def to_have_url(url_or_regex, ignoreCase: nil, timeout: nil)
      base_url = @page.context.send(:base_url)
      if url_or_regex.is_a?(String) && base_url
        expected = URI.join(base_url, url_or_regex).to_s
      else
        expected = url_or_regex
      end
      expected_text = to_expected_text_values(
        [expected],
        ignore_case: ignoreCase,
      )

      expect_impl(
        "to.have.url",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        expected,
        "Page URL expected to be",
        'Expect "to_have_url"',
      )
    end
    _define_negation :to_have_url
  end
end
