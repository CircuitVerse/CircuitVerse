# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentForm::AssignmentFormComponent, type: :component do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @current_user = FactoryBot.create(:user)
    @lms_integration_tutorial = "https://docs.circuitverse.org/#/chapter2/3lmsintegration"
  end

  it "renders the assignment form correctly" do
    render_inline(described_class.new(@assignment, @group, @current_user, @lms_integration_tutorial))
  end
end
