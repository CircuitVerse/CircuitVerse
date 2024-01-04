# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentCard::AssignmentCardComponent, type: :component do
  include Pundit::Authorization
  include Devise::Controllers::Helpers

  before do
    @current_user = FactoryBot.create(:user)
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)

    render_inline(described_class.new(@assignment, @primary_mentor, @group, {
                                        minute: 30, day: 15, year: 2023, second: 0, hour: 12, month: 10
                                      }))
  end

  it "renders the assignment card correctly" do
    expect(page).to have_text(@assignment.name)
    expect(page).to have_text(@assignment.deadline)
    expect(page).to have_text(I18n.t("view"))
    expect(page).to have_text(I18n.t("close"))
    expect(page).to have_text(I18n.t("edit"))
    expect(page).to have_text(I18n.t("delete"))
    expect(page).to have_text("Graded")
  end

  it "renders lms credentials link when lms enabled" do
    allow(Flipper).to receive(:enabled?).with(:lms_integration, @primary_mentor).and_return(true)
    allow(policy(@group)).to receive(:admin_access?).and_return(true)
    allow(@assignment).to receive(:lti_integrated?).and_return(true)

    render_inline(described_class.new(@assignment, @primary_mentor, @group, {
                                        minute: 30, day: 15, year: 2023, second: 0, hour: 12, month: 10
                                      }))

    expect(page).to have_link("Show LMS Credentials")
  end
end
