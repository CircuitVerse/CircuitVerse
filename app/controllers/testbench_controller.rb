# frozen_string_literal: true

class TestbenchController < ApplicationController
  skip_after_action :verify_authorized

  def creator; end
end
