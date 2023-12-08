# frozen_string_literal: true

require "rails_helper"

RSpec.describe AnnouncementBox::AnnouncementComponent, type: :component do
  it "renders the announcement when within the date range" do
    start_date = Date.current - 1
    end_date = Date.current + 1
    current_announcement = instance_double(Announcement, start_date: start_date, end_date: end_date,
                                                         body: "Test announcement", link?: false)

    render_inline(described_class.new(current_announcement))

    expect(page).to have_text("Test announcement")
  end

  it "does not render the announcement when outside the date range" do
    start_date = Date.current + 1
    end_date = Date.current + 2
    current_announcement = instance_double(Announcement, start_date: start_date, end_date: end_date,
                                                         body: "Expired announcement", link?: false)

    render_inline(described_class.new(current_announcement))

    expect(page).not_to have_text("Expired announcement")
  end
end
