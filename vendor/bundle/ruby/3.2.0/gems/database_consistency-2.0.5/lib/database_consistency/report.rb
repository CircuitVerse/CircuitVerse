# frozen_string_literal: true

module DatabaseConsistency
  Report = ReportBuilder.define(
    Class.new,
    :checker_name,
    :table_or_model_name,
    :column_or_attribute_name,
    :status,
    :error_slug,
    :error_message
  )
end
