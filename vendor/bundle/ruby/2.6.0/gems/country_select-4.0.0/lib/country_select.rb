# encoding: utf-8

require 'countries'
require 'sort_alphabetical'

require 'country_select/version'
require 'country_select/formats'
require 'country_select/tag_helper'

if defined?(ActionView::Helpers::Tags::Base)
  require 'country_select/country_select_helper'
else
  require 'country_select/rails3/country_select_helper'
end
