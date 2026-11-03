# frozen_string_literal: true

FactoryBot.define do
  factory :testbench do
    assignment { association(:assignment, group: association(:group, primary_mentor: association(:user))) }
    data do
      { "type" => "comb", "title" => "AND Gate",
        "groups" => [{ "label" => "Group 1", "n" => 2,
                       "inputs" => [{ "label" => "inp1", "bitWidth" => 1, "values" => %w[0 1] }],
                       "outputs" => [{ "label" => "out1", "bitWidth" => 1, "values" => %w[0 1] }] }] }
    end
  end
end
