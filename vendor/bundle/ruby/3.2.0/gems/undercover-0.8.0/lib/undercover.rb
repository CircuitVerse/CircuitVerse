# frozen_string_literal: true

$LOAD_PATH << 'lib'
require 'json'
require 'imagen'
require 'rainbow'
require 'bigdecimal'
require 'forwardable'
require 'simplecov'

require 'undercover/lcov_parser'
require 'undercover/result'
require 'undercover/cli'
require 'undercover/changeset'
require 'undercover/formatter'
require 'undercover/options'
require 'undercover/filter_set'
require 'undercover/simplecov_result_adapter'
require 'undercover/version'

module Undercover
  class Report
    extend Forwardable

    def_delegators :changeset, :validate

    attr_reader :changeset,
                :lcov,
                :coverage_adapter,
                :results,
                :code_dir,
                :filter_set,
                :max_warnings_limit

    # Initializes a new Undercover::Report
    #
    # @param changeset [Undercover::Changeset]
    # @param opts [Undercover::Options]
    # @param coverage_adapter [Undercover::SimplecovResultAdapter|Undercover::LcovParser] pre-parsed coverage adapter
    def initialize(changeset, opts, coverage_adapter)
      @coverage_adapter = coverage_adapter

      @code_dir = opts.path
      @changeset = changeset

      ignored_files = coverage_adapter.ignored_files || []
      @filter_set = FilterSet.new(opts.glob_allow_filters, opts.glob_reject_filters, ignored_files)
      changeset.filter_with(filter_set)
      @max_warnings_limit = opts.max_warnings_limit
      @loaded_files = {}
      @results = {}
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def build
      flag_count = 0
      changeset.each_changed_line do |filepath, line_no|
        break if max_warnings_limit && flag_count >= max_warnings_limit

        dist_from_line_no = lambda do |res|
          return BigDecimal::INFINITY if line_no < res.first_line

          res_lines = res.first_line..res.last_line
          return BigDecimal::INFINITY unless res_lines.cover?(line_no)

          line_no - res.first_line
        end
        dist_from_line_no_sorter = lambda do |res1, res2|
          dist_from_line_no[res1] <=> dist_from_line_no[res2]
        end

        load_and_parse_file(filepath)

        next unless loaded_files[filepath]

        res = loaded_files[filepath].min(&dist_from_line_no_sorter)
        if res.uncovered?(line_no) && !res.flagged?
          res.flag
          flag_count += 1
        end
        results[filepath] ||= Set.new
        results[filepath] << res
      end
      self
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def build_warnings
      warn('Undercover::Report#build_warnings is deprecated! ' \
           'Please use the #flagged_results accessor instead.')
      all_results.select(&:flagged?)
    end

    def all_results
      results.values.map(&:to_a).flatten
    end

    def flagged_results
      all_results.select(&:flagged?)
    end

    def inspect
      "#<Undercover::Report:#{object_id} results: #{results.size}>"
    end
    alias to_s inspect

    private

    attr_reader :loaded_files

    # rubocop:disable Metrics/AbcSize
    def load_and_parse_file(filepath)
      key = filepath.gsub(/^\.\//, '')
      return if loaded_files[key]

      root_ast = Imagen::Node::Root.new.build_from_file(
        File.join(code_dir, filepath)
      )
      return if root_ast.children.empty?

      loaded_files[key] = []
      root_ast.find_all(->(node) { !node.is_a?(Imagen::Node::Root) }).each do |imagen_node|
        loaded_files[key] << Result.new(imagen_node, coverage_adapter, filepath)
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
