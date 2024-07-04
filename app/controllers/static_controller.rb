# frozen_string_literal: true

# app/controllers/static_controller.rb

class StaticController < ApplicationController
  def simulatorvue
    render file: Rails.public_path.join("simulatorvue","v1", "index.html"), layout: false
  end
end
