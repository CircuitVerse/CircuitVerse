class PrependedController < ApplicationController
  # order matters, only prepend then include causes the issue
  prepend Module.new
  include Remotipart::RenderOverrides

  def show
    render
  end
end