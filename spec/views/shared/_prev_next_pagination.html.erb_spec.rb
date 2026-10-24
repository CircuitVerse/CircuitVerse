# frozen_string_literal: true

require "rails_helper"

RSpec.describe "shared/_prev_next_pagination.html.erb", type: :view do
  def render_nav(pagy)
    render partial: "shared/prev_next_pagination", locals: { pagy: pagy }
  end

  it "renders nothing when there is only one page" do
    render_nav(Pagy.new(count: 5, page: 1, limit: 9))

    expect(rendered).not_to include("pagination")
  end

  it "links both directions on a middle page" do
    render_nav(Pagy.new(count: 30, page: 2, limit: 9))

    expect(rendered).to have_link(I18n.t!("pagination.previous_label_html").gsub("&#8592;", "←"))
    expect(rendered).to have_link(I18n.t!("pagination.next_label_html").gsub("&#8594;", "→"))
    expect(rendered).not_to include("page-item disabled")
  end

  it "disables Previous on the first page" do
    render_nav(Pagy.new(count: 30, page: 1, limit: 9))

    expect(rendered).to have_css("li.page-item.disabled span.page-link", text: "Previous")
    expect(rendered).to have_css("a.page-link[rel='next']")
  end

  it "disables Next on the last page" do
    render_nav(Pagy.new(count: 30, page: 4, limit: 9))

    expect(rendered).to have_css("li.page-item.disabled span.page-link", text: "Next")
    expect(rendered).to have_css("a.page-link[rel='prev']")
  end

  it "uses the current locale's labels" do
    I18n.with_locale(:hi) { render_nav(Pagy.new(count: 30, page: 2, limit: 9)) }

    expect(rendered).to include("पिछला")
    expect(rendered).to include("अगला")
  end
end
