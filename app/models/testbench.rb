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

      groups.each { |group| validate_group(group) }
    end

    def validate_group(group)
      cases = group.is_a?(Hash) ? group["n"] : nil
      return errors.add(:data, "group needs a case count") unless cases.is_a?(Integer) && cases.positive?

      %w[inputs outputs].each do |side|
        signals = group[side]
        next errors.add(:data, "group needs #{side}") unless signals.is_a?(Array) && signals.any?

        signals.each { |signal| validate_signal(signal, cases) }
      end
    end

    def validate_signal(signal, cases)
      return errors.add(:data, "every signal needs a label") unless signal.is_a?(Hash) && signal["label"].present?

      label = signal["label"]
      width = signal["bitWidth"]
      errors.add(:data, "#{label} needs a bit width") unless width.is_a?(Integer) && width.positive?
      return if signal["values"].is_a?(Array) && signal["values"].size == cases

      errors.add(:data, "#{label} needs #{cases} values")
    end
end
