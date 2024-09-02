# frozen_string_literal: true

# app/controllers/static_controller.rb

class StaticController < ApplicationController
  def simulatorvue
    version = params[:simver] || "v0"
    render file: Rails.public_path.join("simulatorvue", version, "index-cv.html"), layout: false
  end
end
