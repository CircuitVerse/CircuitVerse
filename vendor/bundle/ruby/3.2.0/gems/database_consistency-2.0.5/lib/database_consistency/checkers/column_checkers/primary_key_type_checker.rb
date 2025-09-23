# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks that primary key is bigserial, bigint, or uuid
    class PrimaryKeyTypeChecker < ColumnChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :fk_name,
        :table_to_change,
        :type_to_set
      )

      private

      VALID_TYPES = %w[bigserial bigint uuid].freeze
      VALID_TYPES_MAP = {
        'serial' => 'bigserial',
        'integer' => 'bigint'
      }.freeze
      SQLITE_ADAPTER_NAME = 'SQLite'

      # We skip check when:
      #  - column is not a primary key
      #  - database is SQLite3
      def preconditions
        primary_field? && !sqlite?
      end

      # Table of possible statuses
      # | bigint/bigserial/uuid | status |
      # | --------------------- | ------ |
      # | yes                   | ok     |
      # | no                    | fail   |
      def check
        if valid?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :small_primary_key)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          table_to_change: model.table_name,
          fk_name: column.name,
          type_to_set: type_to_set,
          **report_attributes
        )
      end

      def type_to_set
        VALID_TYPES_MAP[column.sql_type.to_s] || 'bigserial'
      end

      # @return [Boolean]
      def valid?
        VALID_TYPES.any? do |type|
          column.sql_type.to_s.match?(type)
        end
      end

      # @return [Boolean]
      def primary_field?
        column.name.to_s == model.primary_key.to_s
      end

      # @return [Boolean]
      def sqlite?
        model.connection.adapter_name == SQLITE_ADAPTER_NAME
      end
    end
  end
end
