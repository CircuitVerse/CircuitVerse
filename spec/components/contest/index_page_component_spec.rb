# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::IndexPageComponent, type: :component do
  it "renders at least one contest card" do
    create(:contest, :completed)

    contests = Contest.paginate(page: 1)

    render_inline(
      described_class.new(
        contests: contests,
        current_user: build_stubbed(:user),
        notice: nil
      )
    )

    expect(page).to have_css(".contest-card")
  end
end
