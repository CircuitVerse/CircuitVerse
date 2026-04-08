# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    @cores = [
      { name: "Aboobacker MK",
        img: "https://avatars.githubusercontent.com/u/3112976?s=96&v=4", link: "https://github.com/tachyons" },
      { name: "Ruturaj Mohite",
        img: "https://avatars.githubusercontent.com/u/53974118?v=4", link: "https://github.com/gr455" },
      { name: "Nitin Singhal",
        img: "https://avatars.githubusercontent.com/u/16988558?s=96&v=4", link: "https://github.com/nitin10s" },
      { name: "Satvik Ramaprasad",
        img: "https://avatars.githubusercontent.com/u/2092958?s=96&v=4", link: "https://github.com/satu0king" },
      { name: "Vedant Jain",
        img: "https://avatars.githubusercontent.com/u/76901313?v=4", link: "https://github.com/vedant-jain03" },
      { name: "Pulkit Gupta",
        img: "https://avatars.githubusercontent.com/u/76155456?v=4", link: "https://github.com/pulkit-30" },
      { name: "Vaibhav Upreti",
        img: "https://avatars.githubusercontent.com/u/85568177?v=4", link: "https://github.com/VaibhavUpreti" },
      { name: "Arnabdaz",
        img: "https://avatars.githubusercontent.com/u/96580571?v=4", link: "https://github.com/Arnabdaz" },
      { name: "Aditya Umesh Singh",
        img: "https://avatars.githubusercontent.com/u/177742943?v=4", link: "https://github.com/salmoneatenbybear" },
      { name: "Harsh Rao",
        img: "https://avatars.githubusercontent.com/u/166894150?v=4", link: "https://github.com/ThatDeparted2061" },
      { name: "Nihal Rajpal",
        img: "https://avatars.githubusercontent.com/u/65150640?v=4", link: "https://github.com/nihal4777" },
      { name: "Yashvant Singh",
        img: "https://avatars.githubusercontent.com/u/146776812?v=4", link: "https://github.com/JatsuAkaYashvant" },
      { name: "Harsh Bhadu",
        img: "https://avatars.githubusercontent.com/u/102225113?v=4", link: "https://github.com/senbo1" },
      { name: "Aman Asrani",
        img: "https://avatars.githubusercontent.com/u/96644946?v=4", link: "https://github.com/Asrani-Aman" },
      { name: "Hardik Sachdeva",
        img: "https://avatars.githubusercontent.com/u/85028179?v=4", link: "https://github.com/hardik17771" }
    ]

    @mentors = []

    @alumni = [
      { name: "Aayush Gupta", img: "https://avatars.githubusercontent.com/u/47032027?v=4",
        link: "https://github.com/aayush-05" },
      { name: "Shreya Prasad", img: "https://avatars.githubusercontent.com/u/43600306?s=96&v=4",
        link: "https://github.com/ShreyaPrasad1209" },
      { name: "Shubhankar Sharma",
        img: "https://avatars.githubusercontent.com/u/32474302?s=96&v=4",
        link: "https://github.com/shubhankarsharma00" },
      { name: "Manjot Sidhu",
        img: "https://avatars.githubusercontent.com/u/22657113?s=96&v=4", link: "https://github.com/manjotsidhu" },
      { name: "Samiran Konwar",
        img: "https://avatars.githubusercontent.com/u/42478217?v=4", link: "https://github.com/abstrekt" },
      { name: "AYAN BISWAS",
        img: "https://avatars.githubusercontent.com/u/52851184?s=96&v=4", link: "https://github.com/ayan-biswas0412" },
      { name: "Nitish Aggarwal",
        img: "https://avatars.githubusercontent.com/u/45434030?s=96&v=4", link: "https://github.com/Nitish145" },
      { name: "Pavan Joshi",
        img: "https://avatars.githubusercontent.com/u/55848322?s=96&v=4", link: "https://github.com/pavanjoshi914" },
      { name: "Biswesh Mohapatra",
        img: "https://avatars.githubusercontent.com/u/24248795?v=4", link: "https://github.com/biswesh456" },
      { name: "Shivansh Srivastava",
        img: "https://avatars.githubusercontent.com/u/42182955?s=96&v=4", link: "https://github.com/Shivansh2407" },
      { name: "Abhishek Zade",
        img: "https://avatars.githubusercontent.com/u/66520848?s=96&v=4", link: "https://github.com/ZadeAbhishek" },
      { name: "Devjit Choudhury",
        img: "https://avatars.githubusercontent.com/u/61665451?v=4", link: "https://github.com/devartstar" },
      { name: "Aman Singh",
        img: "https://avatars.githubusercontent.com/u/77198905?v=4", link: "https://github.com/aman-singh7" },
      { name: "Prerna Sharma",
        img: "https://avatars.githubusercontent.com/u/89515816?v=4", link: "https://github.com/Prerna-0202" },
      { name: "Tanmoy Sarkar",
        img: "https://avatars.githubusercontent.com/u/57363826?v=4", link: "https://github.com/tanmoysrt" }
    ]

    @issues_triaging = [
      { name: "Yashvant Singh",
        img: "https://avatars.githubusercontent.com/u/146776812?v=4", link: "https://github.com/JatsuAkaYashvant" },
      { name: "Ghanshyam Singh",
        img: "https://avatars.githubusercontent.com/u/56252619?v=4", link: "https://github.com/ghanshyam2005singh" },
      { name: "Harsh Bhadu",
        img: "https://avatars.githubusercontent.com/u/102225113?v=4", link: "https://github.com/senbo1" },
      { name: "Supreeth C",
        img: "https://avatars.githubusercontent.com/u/141218988?v=4", link: "https://github.com/ShinichiShi" },
      { name: "Radhika Chauhan",
        img: "https://avatars.githubusercontent.com/u/148184013?v=4", link: "https://github.com/Radhikaa-chauhan" },
      { name: "ANIRUDDH",
        img: "https://avatars.githubusercontent.com/u/149250431?v=4", link: "https://github.com/blazethunderstorm" },
      { name: "Himanshu Jayswal",
        img: "https://avatars.githubusercontent.com/u/158487820?v=4", link: "https://github.com/himanshujays29" },
      { name: "Naman Chhabra",
        img: "https://avatars.githubusercontent.com/u/159947791?v=4", link: "https://github.com/naman79820" },
      { name: "Yana Pandey",
        img: "https://avatars.githubusercontent.com/u/173885830?v=4", link: "https://github.com/Yana-do-code" },
      { name: "Himanshu Soni",
        img: "https://avatars.githubusercontent.com/u/183348352?v=4", link: "https://github.com/h30s" }
    ]
  end
end
