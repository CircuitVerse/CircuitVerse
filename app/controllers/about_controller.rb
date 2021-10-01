# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    @cores = [{ name: "Core Member01", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member03", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member04", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member05", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member06", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member07", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member08", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member09", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
    { name: "Core Member10", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" }
]

@mentors = [{ name: "Mentor02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Mentor02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Mentor02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Mentor02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Mentor02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" }
]

@alumni = [{ name: "Alumni01", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Alumni02", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Alumni03", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Alumni04", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" },
{ name: "Alumni05", img: "https://avatars.githubusercontent.com/u/40604582?v=4", link: "#" }
]
    end
end
