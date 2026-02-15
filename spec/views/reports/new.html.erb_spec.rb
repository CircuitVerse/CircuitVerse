# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reports/new.html.erb", type: :view do
  before do
    reported_user = create(:user)
    assign(:reported_user, reported_user)
    assign(:report, Report.new(reported_user: reported_user))

    # Stub route helper in case it's not available in view context
    allow(view).to receive(:root_path).and_return("/")
  end

  it "renders the report form" do
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_field("report_reason")
    expect(rendered).to have_field("report_description")
    expect(rendered).to have_button("Submit Report")
  end
end
