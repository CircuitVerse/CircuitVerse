# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    @cores = [{ name: "Core Member01", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member02", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member03", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member04", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member05", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member06", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member07", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member08", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member09", img: "https://picsum.photos/100/180", link: "#" },
              { name: "Core Member10", img: "https://picsum.photos/100/180", link: "#" }]

    @mentors = [{ name: "Mentor01", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Mentor02", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Mentor03", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Mentor04", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Mentor05", img: "https://picsum.photos/100/180", link: "#" }]

    @_alumni = [{ name: "Alumni01", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Alumni02", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Alumni04", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Alumni05", img: "https://picsum.photos/100/180", link: "#" },
                { name: "Alumni06", img: "https://picsum.photos/100/180", link: "#" }]
  end
end
