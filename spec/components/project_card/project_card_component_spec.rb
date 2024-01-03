# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectCard::ProjectCardComponent, type: :component do
  before do
    @author = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @author)
  end

  it "renders the project card correctly" do
    render_inline(described_class.new(@project, @author))
  end
end
