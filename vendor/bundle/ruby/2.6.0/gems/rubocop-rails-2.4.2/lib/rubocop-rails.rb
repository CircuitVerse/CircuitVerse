# frozen_string_literal: true

require 'rubocop'
require 'rack/utils'

require_relative 'rubocop/rails'
require_relative 'rubocop/rails/version'
require_relative 'rubocop/rails/inject'

RuboCop::Rails::Inject.defaults!

require_relative 'rubocop/cop/rails_cops'
