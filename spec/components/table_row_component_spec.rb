# frozen_string_literal: true

require "rails_helper"

RSpec.describe TableRow::TableRowComponent, type: :component do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @current_user = FactoryBot.create(:user)
  end

  it "renders the assignment row correctly" do
    render_inline(described_class.new(
                    @assignment,
                    @current_user,
                    @group,
                    { minute: 30, day: 15, year: 2023, second: 0, hour: 12, month: 10 }
                  ))
  end
end
