# app/controllers/vuesimulator_controller.rb
# frozen_string_literal: true

class VuesimulatorController < ApplicationController
  def simulatorvue
    html = File.read(Rails.public_path.join("simulatorvue/index.html"))
    render html: html.html_safe, layout: false
  end
end
