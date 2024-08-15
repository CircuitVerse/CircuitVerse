# encoding: utf-8

require 'spec_helper'

require 'action_view'
require 'country_select'

describe "CountrySelect" do
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormOptionsHelper

  before do
    I18n.available_locales = [:en]
    I18n.locale = :en
    ISO3166.reset
  end

  class Walrus
    attr_accessor :country_code
  end

  let(:walrus) { Walrus.new }
  let!(:template) { ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil) }

  let(:builder) do
    if defined?(ActionView::Helpers::Tags::Base)
      ActionView::Helpers::FormBuilder.new(:walrus, walrus, template, {})
    else
      ActionView::Helpers::FormBuilder.new(:walrus, walrus, template, {}, Proc.new { })
    end
  end

  let(:select_tag) do
    <<-EOS.chomp.strip
      <select id="walrus_country_code" name="walrus[country_code]">
    EOS
  end

  it "selects the value of country_code" do
    tag = options_for_select([['United States', 'US']], 'US')

    walrus.country_code = 'US'
    t = builder.country_select(:country_code)
    expect(t).to include(tag)
  end

  it "uses the locale specified by I18n.locale" do
    I18n.available_locales = [:en, :es]
    ISO3166.reset

    tag = options_for_select([['Estados Unidos', 'US']], 'US')

    walrus.country_code = 'US'
    original_locale = I18n.locale
    begin
      I18n.locale = :es
      t = builder.country_select(:country_code)
      expect(t).to include(tag)
    ensure
      I18n.locale = original_locale
    end
  end

  it 'falls back when given a country-specific locale' do
    I18n.available_locales = [:en, :de, :'de-AT']
    ISO3166.reset

    tag = options_for_select([['Deutschland', 'DE']], 'DE')

    walrus.country_code = 'DE'
    original_locale = I18n.locale
    begin
      I18n.locale = :'de-AT'
      t = builder.country_select(:country_code)
      expect(t).to include(tag)
    ensure
      I18n.locale = original_locale
    end
  end

  it "accepts a locale option" do
    I18n.available_locales = [:fr]
    ISO3166.reset

    tag = options_for_select([['États-Unis', 'US']], 'US')

    walrus.country_code = 'US'
    t = builder.country_select(:country_code, locale: :fr)
    expect(t).to include(tag)
  end

  it "accepts priority countries" do
    tag = options_for_select(
      [
        ['Denmark', 'DK'],
        ['Latvia','LV'],
        ['United States','US'],
        ['-'*15,'-'*15]
      ],
      selected: 'US',
      disabled: '-'*15
    )

    walrus.country_code = 'US'
    t = builder.country_select(:country_code, priority_countries: ['LV','US','DK'])
    expect(t).to include(tag)
  end

  it "priority countries are sorted by name by default" do
    tag = options_for_select(
      [
        ['Denmark', 'DK'],
        ['Latvia','LV'],
        ['United States','US'],
        ['-'*15,'-'*15]
      ],
      selected: 'US',
      disabled: '-'*15
    )

    walrus.country_code = 'US'
    t = builder.country_select(:country_code, priority_countries: ['LV','US','DK'])
    expect(t).to include(tag)
  end

  it "priority countries with `sort_provided: false` preserves the provided order" do
    tag = options_for_select(
      [
        ['Latvia','LV'],
        ['United States','US'],
        ['Denmark', 'DK'],
        ['-'*15,'-'*15]
      ],
      selected: 'US',
      disabled: '-'*15
    )

    walrus.country_code = 'US'
    t = builder.country_select(:country_code, priority_countries: ['LV','US','DK'], sort_provided: false)
    expect(t).to include(tag)
  end

  it "priority countries with `sort_provided: false` still sorts the non-priority countries by name" do
    tag = options_for_select(
      [
        ['Latvia','LV'],
        ['United States','US'],
        ['Denmark', 'DK'],
        ['-'*15,'-'*15],
        ['Afghanistan','AF']
      ],
      selected: 'AF',
      disabled: '-'*15
    )

    walrus.country_code = 'AF'
    t = builder.country_select(:country_code, priority_countries: ['LV','US','DK'], sort_provided: false)
    expect(t).to include(tag)
  end

  describe "when selected options is not an array" do
    it "selects only the first matching option" do
      tag = options_for_select([["United States", "US"],["Uruguay", "UY"]], "US")
      walrus.country_code = 'US'
      t = builder.country_select(:country_code, priority_countries: ['LV','US'])
      expect(t).to_not include(tag)
    end
  end

  describe "when selected options is an array" do
    it "selects all options but only once" do
      walrus.country_code = 'US'
      t = builder.country_select(:country_code, {priority_countries: ['LV','US','ES'], selected: ['UY', 'US']}, multiple: true)
      expect(t.scan(options_for_select([["United States", "US"]], "US")).length).to be(1)
      expect(t.scan(options_for_select([["Uruguay", "UY"]], "UY")).length).to be(1)
    end
  end

  it "displays only the chosen countries" do
    options = [["Denmark", "DK"],["Germany", "DE"]]
    tag = builder.select(:country_code, options)
    walrus.country_code = 'US'
    t = builder.country_select(:country_code, only: ['DK','DE'])
    expect(t).to eql(tag)
  end

  it "discards some countries" do
    tag = options_for_select([["United States", "US"]])
    walrus.country_code = 'DE'
    t = builder.country_select(:country_code, except: ['US'])
    expect(t).to_not include(tag)
  end

  it "countries provided in `only` are sorted by name by default" do
    t = builder.country_select(:country_code, only: ['PT','DE','AR'])
    order = t.scan(/value="(\w{2})"/).map { |o| o[0] }
    expect(order).to eq(['AR', 'DE', 'PT'])
  end

  it "countries provided in `only` with `sort_provided` to false keeps the order of the provided countries" do
    t = builder.country_select(:country_code, only: ['PT','DE','AR'], sort_provided: false)
    order = t.scan(/value="(\w{2})"/).map { |o| o[0] }
    expect(order).to eq(['PT','DE','AR'])
  end

  context "when there is a default 'except' configured" do
    around do |example|
      old_value = ::CountrySelect::DEFAULTS[:except]
      example.run
      ::CountrySelect::DEFAULTS[:except] = old_value
    end

    it "discards countries when configured to" do
      ::CountrySelect::DEFAULTS[:except] = ['US']

      tag = options_for_select([['United States', 'US']])
      walrus.country_code = 'DE'
      t = builder.country_select(:country_code)
      expect(t).to_not include(tag)
    end
  end

  context "using old 1.x syntax" do
    it "accepts priority countries" do
      tag = options_for_select(
        [
          ['Denmark', 'DK'],
          ['Latvia','LV'],
          ['United States','US'],
          ['-'*15,'-'*15]
        ],
        selected: 'US',
        disabled: '-'*15
      )

      walrus.country_code = 'US'
      t = builder.country_select(:country_code, ['LV','US','DK'])
      expect(t).to include(tag)
    end

    it "selects only the first matching option" do
      tag = options_for_select([["United States", "US"],["Uruguay", "UY"]], "US")
      walrus.country_code = 'US'
      t = builder.country_select(:country_code, ['LV','US'])
      expect(t).to_not include(tag)
    end

    it "supports the country names as provided by default in Formtastic" do
      tag = options_for_select([
        ["Australia", "AU"],
        ["Canada", "CA"],
        ["United Kingdom", "GB"],
        ["United States", "US"]
      ])
      country_names = ["Australia", "Canada", "United Kingdom", "United States"]
      t = builder.country_select(:country_code, country_names)
      expect(t).to include(tag)
    end

    it "raises an error when a country code or name is not found" do
      country_names = [
        "United States",
        "Canada",
        "United Kingdom",
        "Mexico",
        "Australia",
        "Freedonia"
      ]
      error_msg = "Could not find Country with string 'Freedonia'"

      expect do
        builder.country_select(:country_code, country_names)
      end.to raise_error(CountrySelect::CountryNotFoundError, error_msg)
    end

    it "supports the select prompt" do
      tag = '<option value="">Select your country</option>'
      t = builder.country_select(:country_code, prompt: 'Select your country')
      expect(t).to include(tag)
    end

    it "supports the include_blank option" do
      # Rails 6.1 more closely follows the HTML spec for
      # empty option tags.
      # https://github.com/rails/rails/pull/39808
      tag = if ActionView::VERSION::STRING >= '6.1'
              '<option value="" label=" "></option>'
            else
              '<option value=""></option>'
            end
      t = builder.country_select(:country_code, include_blank: true)
      expect(t).to include(tag)
    end
  end

  it 'sorts unicode' do
    tag = builder.country_select(:country_code, only: ['AX', 'AL', 'AF', 'ZW'])
    order = tag.scan(/value="(\w{2})"/).map { |o| o[0] }
    expect(order).to eq(['AF', 'AX', 'AL', 'ZW'])
  end

  describe "custom formats" do
    it "accepts a custom formatter" do
      ::CountrySelect::FORMATS[:with_alpha2] = lambda do |country|
        "#{country.iso_short_name} (#{country.alpha2})"
      end

      tag = options_for_select([['United States of America (US)', 'US']], 'US')

      walrus.country_code = 'US'
      t = builder.country_select(:country_code, format: :with_alpha2)
      expect(t).to include(tag)
    end

    it "accepts an array for formatter" do
      ::CountrySelect::FORMATS[:with_alpha3] = lambda do |country|
        [country.iso_short_name, country.alpha3]
      end

      tag = options_for_select([['United States of America', 'USA']], 'USA')
      walrus.country_code = 'USA'
      t = builder.country_select(:country_code, format: :with_alpha3)
      expect(t).to include(tag)
    end

    it "accepts an array for formatter + custom formatter" do
      ::CountrySelect::FORMATS[:with_alpha3] = lambda do |country|
        ["#{country.iso_short_name} (#{country.alpha2})", country.alpha3]
      end

      tag = options_for_select([['United States of America (US)', 'USA']], 'USA')
      walrus.country_code = 'USA'
      t = builder.country_select(:country_code, format: :with_alpha3)
      expect(t).to include(tag)
    end

    it "marks priority countries as selected only once" do
      ::CountrySelect::FORMATS[:with_alpha3] = lambda do |country|
        [country.iso_short_name, country.alpha3]
      end

      tag = options_for_select([['United States of America', 'USA']], 'USA')
      walrus.country_code = 'USA'
      t = builder.country_select(:country_code, format: :with_alpha3, priority_countries: ['US'])
      expect(t.scan(Regexp.new(Regexp.escape(tag))).size).to eq 1
    end
  end
end
