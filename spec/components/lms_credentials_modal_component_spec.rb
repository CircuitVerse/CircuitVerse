# frozen_string_literal: true

require "rails_helper"

RSpec.describe LmsCredentialsModal::LmsCredentialsModalComponent, type: :component do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @lms_integration_tutorial = "https://docs.circuitverse.org/#/chapter2/3lmsintegration"

    render_inline(described_class.new(@assignment, @lms_integration_tutorial))
  end

  it "renders the assignment card correctly" do
    expect(page).to have_text("LMS Credentials")
    expect(page).to have_text(@assignment.name)
    expect(page).to have_text("Learn how to integrate CircuitVerse assignments with any LMS")
    expect(page).to have_text("Tool Url")
    expect(page).to have_text("Consumer Key")
    expect(page).to have_text("Shared Secret")
  end
end
