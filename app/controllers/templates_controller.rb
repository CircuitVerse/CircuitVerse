# frozen_string_literal: true

class TemplatesController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @tag = Tag.named(params[:tag]) if params[:tag].present?
    @templates = Project.templates_for(current_user).where.not(project_access_type: "Private")
    @templates = @templates.name_like(params[:q]) if params[:q].present?
    @templates = @templates.joins(:tags).where(tags: { id: @tag&.id }) if params[:tag].present?
    @templates = @templates.includes(:author, :stars, :template_assignments).with_attached_circuit_preview
                           .order(id: :desc).paginate(page: params[:page])
  end
end
