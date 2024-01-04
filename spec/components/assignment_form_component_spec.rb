# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentForm::AssignmentFormComponent, type: :component do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @lms_integration_tutorial = "https://docs.circuitverse.org/#/chapter2/3lmsintegration"

    render_inline(described_class.new(@assignment, @group, @primary_mentor, @lms_integration_tutorial))
  end

  it "renders the assignment form fields correctly" do
    expect(page).to have_text("Name")
    expect(page).to have_text("Description")
    expect(page).to have_text("Deadline")
    expect(page).to have_text("Grading scale")
  end

  it "renders the assignment form buttons correctly" do
    puts page.text
    expect(page).to have_text("Enable elements restriction")
    expect(page).to have_text("Enable feature restriction")
    expect(page).to have_text(I18n.t("back"))
  end

  it "renders the integrate with lms button when enabled" do
    allow(Flipper).to receive(:enabled?).with(:lms_integration, @primary_mentor).and_return(true)

    render_inline(described_class.new(@assignment, @group, @primary_mentor, @lms_integration_tutorial))

    puts page.text

    expect(page).to have_text("Integrate with LMS")
    expect(page).to have_text("We will generate the required keys for integration after assignment creation.Learn how to integrate CircuitVerse assignments with any LMS")
  end
end
