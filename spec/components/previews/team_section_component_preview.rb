# frozen_string_literal: true

class TeamSectionComponentPreview < ViewComponent::Preview
  def default
    render(AboutPageComponents::TeamSectionComponent.new(
             title: "CORE TEAM",
             description: "CircuitVerse is lead by an experienced team that is dedicated to innovation and excellence.",
             members: sample_core_members,
             section_id: "core-team"
           ))
  end

  private

    def sample_core_members
      [
        { name: "Aboobacker MK", img: "https://avatars.githubusercontent.com/u/3112976?s=96&v=4",
          link: "https://github.com/tachyons" },
        { name: "Ruturaj Mohite", img: "https://avatars.githubusercontent.com/u/53974118?v=4",
          link: "https://github.com/gr455" },
        { name: "Nitin Singhal", img: "https://avatars.githubusercontent.com/u/16988558?s=96&v=4", link: "https://github.com/nitin10s" }
      ]
    end
end
