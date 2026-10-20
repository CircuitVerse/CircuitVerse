# frozen_string_literal: true

class TemplatesController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @templates = Project.where(is_template: true).template_public
    @templates = @templates.name_like(params[:q]) if params[:q].present?
    @templates = @templates.joins(:tags).where(tags: { id: Tag.named(params[:tag])&.id }) if params[:tag].present?
    @templates = @templates.includes(:author, :stars).with_attached_circuit_preview
                           .order(id: :desc).paginate(page: params[:page])
  end
end
