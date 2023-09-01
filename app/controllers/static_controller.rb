# frozen_string_literal: true

# app/controllers/static_controller.rb

class StaticController < ApplicationController
  def simulatorvue
    render file: Rails.root.join('public', 'simulatorvue', 'index.html'), layout: false
  end
end
