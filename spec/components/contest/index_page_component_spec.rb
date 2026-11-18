# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::IndexPageComponent, type: :component do
  it "renders at least one contest card" do
    create(:contest, :completed)

    contests = Contest.order(id: :desc).limit(Contest::PER_PAGE)
    pagy = Pagy.new(count: Contest.count, page: 1, limit: Contest::PER_PAGE)

    render_inline(
      described_class.new(
        contests: contests,
        pagy: pagy,
        current_user: build_stubbed(:user),
        notice: nil
      )
    )

    expect(page).to have_css(".contest-card")
  end
end
