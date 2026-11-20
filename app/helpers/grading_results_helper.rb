# frozen_string_literal: true

module GradingResultsHelper
  def visible_test_groups(result, reveal_hidden)
    snapshot = result.suite_snapshot["groups"] || []
    result.breakdown.each_with_index.flat_map do |group, i|
      hidden = snapshot.dig(i, "hidden") && !reveal_hidden
      Array(group["cases"]).each_with_index.map do |c, j|
        { "label" => case_label(group["label"], j),
          "passed" => c["passed"], "hidden" => hidden,
          "inputs" => hidden ? nil : pin_values(snapshot.dig(i, "inputs"), j),
          "outputs" => hidden ? nil : pin_values(snapshot.dig(i, "outputs"), j) }
      end
    end
  end

  private

    def case_label(group_label, index)
      [group_label, "case #{index + 1}"].compact.join(" - ")
    end

    def pin_values(pins, index)
      Array(pins).map { |pin| pin.merge("values" => [pin["values"]&.[](index)]) }
    end
end
