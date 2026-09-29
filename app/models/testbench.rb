# frozen_string_literal: true

class Testbench < ApplicationRecord
  TYPES = %w[comb seq].freeze

  belongs_to :assignment

  validates :assignment_id, uniqueness: true
  validate :data_is_runnable

  def groups
    data.is_a?(Hash) ? Array(data["groups"]) : []
  end

  private

    # A malformed suite fails every case in the simulator, reading as the student's mistake.
    def data_is_runnable
      return errors.add(:data, "must be a testbench object") unless data.is_a?(Hash)

      errors.add(:data, "type must be comb or seq") unless TYPES.include?(data["type"])
      return errors.add(:data, "must define a group") if groups.empty?

      groups.each_with_index { |group, index| validate_group(group, index.zero? ? nil : groups.first) }
    end

    def validate_group(group, reference)
      cases = group.is_a?(Hash) ? group["n"] : nil
      return errors.add(:data, "group needs a case count") unless cases.is_a?(Integer) && cases.positive?

      %w[inputs outputs].each do |side|
        signals = group[side]
        next errors.add(:data, "group needs #{side}") unless signals.is_a?(Array) && signals.any?

        signals.each { |signal| validate_signal(signal, cases) }
        next unless reference

        shape = ->(list) { list.map { |s| [s["label"], s["bitWidth"]] } }
        next if shape.call(signals) == shape.call(reference[side])

        errors.add(:data, "#{side} must match the first group's signals")
      end
    end

    def validate_signal(signal, cases)
      label = signal.is_a?(Hash) ? signal["label"] : nil
      return errors.add(:data, "every signal needs a label") unless label.is_a?(String) && label.present?

      width = signal["bitWidth"]
      errors.add(:data, "#{label} needs a bit width") unless width.is_a?(Integer) && width.positive?
      return if valid_values?(signal["values"], cases, width)

      errors.add(:data, "#{label} needs #{cases} #{width}-bit binary values")
    end

    def valid_values?(values, cases, width)
      values.is_a?(Array) && values.size == cases &&
        values.all? { |v| v.is_a?(String) && width.is_a?(Integer) && v.match?(/\A[01]{#{width}}\z/) }
    end
end
