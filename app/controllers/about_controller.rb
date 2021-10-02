# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    @cores = [{ name: "Aayush Gupta", img: "https://avatars.githubusercontent.com/u/47032027?v=4", link: "https://github.com/aayush-05" },
              { name: "Samiran Konwar", img: "https://avatars.githubusercontent.com/u/42478217?v=4", link: "https://github.com/abstrekt" },
              { name: "Aboobacker MK", img: "https://avatars.githubusercontent.com/u/3112976?s=96&v=4", link: "https://github.com/tachyons" },
              { name: "Ruturaj Mohite", img: "https://avatars.githubusercontent.com/u/53974118?v=4", link: "https://github.com/gr455" },
              { name: "Manjot Sidhu", img: "https://avatars.githubusercontent.com/u/22657113?s=96&v=4", link: "https://github.com/manjotsidhu" },
              { name: "Nitin Singhal", img: "https://avatars.githubusercontent.com/u/16988558?s=96&v=4", link: "https://github.com/nitin10s" },
              { name: "AYAN BISWAS", img: "https://avatars.githubusercontent.com/u/52851184?s=96&v=4", link: "https://github.com/ayan-biswas0412" },
              { name: "Nitish Aggarwal", img: "https://avatars.githubusercontent.com/u/45434030?s=96&v=4", link: "https://github.com/Nitish145" },
              { name: "Pavan Joshi", img: "https://avatars.githubusercontent.com/u/55848322?s=96&v=4", link: "https://github.com/pavanjoshi914" },
              { name: "Shreya Prasad", img: "https://avatars.githubusercontent.com/u/43600306?s=96&v=4", link: "https://github.com/ShreyaPrasad1209" },
              { name: "Shubhankar Sharma", img: "https://avatars.githubusercontent.com/u/32474302?s=96&v=4", link: "https://github.com/shubhankarsharma00" },
              { name: "Satvik Ramaprasad", img: "https://avatars.githubusercontent.com/u/2092958?s=96&v=4", link: "https://github.com/satu0king" },
              { name: "Biswesh Mohapatra", img: "https://avatars.githubusercontent.com/u/24248795?v=4", link: "https://github.com/biswesh456" },
              { name: "Shivansh Srivastava", img: "https://avatars.githubusercontent.com/u/42182955?s=96&v=4", link: "https://github.com/Shivansh2407" },
              { name: "Abhishek Zade", img: "https://avatars.githubusercontent.com/u/66520848?s=96&v=4", link: "https://github.com/ZadeAbhishek" }]

    @mentors = []

    @alumni = []
  end
end
