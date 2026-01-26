# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reports/new.html.erb", type: :view do
  before do
    assign(:report, Report.new)
  end

  it "renders the report form" do
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_field("report_reason")
    expect(rendered).to have_field("report_description")
    expect(rendered).to have_button("Submit Report")
  end
end
