# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks if non polymorphic +belongs_to+ association has foreign key constraint
    class ForeignKeyChecker < AssociationChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :primary_table,
        :primary_key,
        :foreign_table,
        :foreign_key
      )

      private

      # We skip check when:
      #  - underlying models belong to different databases
      #  - association isn't belongs_to association
      #  - association is polymorphic
      def preconditions
        supported? &&
          association.belongs_to? && !association.polymorphic? &&
          same_database? &&
          model.connection.table_exists?(model.table_name)
      rescue NameError
        false
      end

      def same_database?
        Helper.connection_config(model) == Helper.connection_config(association.klass)
      end

      def supported?
        return false if ActiveRecord::VERSION::MAJOR < 5 && Helper.adapter == 'sqlite3'

        true
      end

      # Table of possible statuses
      # | foreign key | status |
      # | ----------- | ------ |
      # | persisted   | ok     |
      # | missing     | fail   |
      def check
        if model.connection.foreign_keys(model.table_name).find { |fk| fk.column == association.foreign_key.to_s }
          report_template(:ok)
        else
          report_template(:fail, error_slug: :missing_foreign_key)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_message: nil,
          error_slug: error_slug,
          primary_table: association.table_name.to_s,
          primary_key: association.association_primary_key.to_s,
          foreign_table: association.active_record.table_name.to_s,
          foreign_key: association.foreign_key.to_s,
          **report_attributes
        )
      end
    end
  end
end
