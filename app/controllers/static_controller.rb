# frozen_string_literal: true

# app/controllers/static_controller.rb

class StaticController < ApplicationController
  def simulatorvue
    render plain: File.read(Rails.public_path.join("simulatorvue", "index.html")), layout: false
  end
end
