# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    @cores = [{ name: "Core Member01", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member02", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member03", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member04", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member05", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member06", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member07", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member08", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member09", img: "http://placehold.it/100x180", link: "#" },
              { name: "Core Member10", img: "http://placehold.it/100x180", link: "#" }]

    @mentors = [{ name: "Mentor01", img: "http://placehold.it/100x180", link: "#" },
                { name: "Mentor02", img: "http://placehold.it/100x180", link: "#" },
                { name: "Mentor03", img: "http://placehold.it/100x180", link: "#" },
                { name: "Mentor04", img: "http://placehold.it/100x180", link: "#" },
                { name: "Mentor05", img: "http://placehold.it/100x180", link: "#" }]

    @_alumni = [{ name: "Alumni01", img: "http://placehold.it/100x180", link: "#" },
                { name: "Alumni02", img: "http://placehold.it/100x180", link: "#" },
                { name: "Alumni04", img: "http://placehold.it/100x180", link: "#" },
                { name: "Alumni05", img: "http://placehold.it/100x180", link: "#" },
                { name: "Alumni06", img: "http://placehold.it/100x180", link: "#" }]
  end
end
