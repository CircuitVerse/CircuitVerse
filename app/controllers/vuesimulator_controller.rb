class VuesimulatorController < ApplicationController
    def simulatorvue
        html = File.read(Rails.root.join("public","simulatorvue","index.html"))
        render html: html.html_safe, layout: false
    end
end