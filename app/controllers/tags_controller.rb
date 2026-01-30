# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :set_tag!

  PER_PAGE = ExploreController::RECENT_LIMIT

  def show
    load_tagged_projects_with_cursor!
  end

  private

    def set_tag!
      @tag = Tag.find_by!(name: params[:tag])
    end

    # rubocop:disable Metrics/MethodLength
    def load_tagged_projects_with_cursor!
      paginator = build_tag_paginator
      page = paginator.fetch

      @projects    = page.records
      @has_prev    = page.has_previous?
      @has_next    = page.has_next?
      @prev_cursor = page.previous_cursor
      @next_cursor = page.next_cursor
    rescue ActiveRecordCursorPaginate::InvalidCursorError => e
      Rails.logger.warn "Tags#show invalid cursor: #{e.message}. Falling back to first page."
      paginator = build_tag_paginator(skip_cursor: true)
      page = paginator.fetch

      @projects    = page.records
      @has_prev    = page.has_previous?
      @has_next    = page.has_next?
      @prev_cursor = page.previous_cursor
      @next_cursor = page.next_cursor
    end
    # rubocop:enable Metrics/MethodLength

    def build_tag_paginator(skip_cursor: false)
      relation = tag_base_scope

      params_hash = {
        order: { id: :desc },
        limit: PER_PAGE
      }

      unless skip_cursor
        params_hash[:after]  = params[:after]
        params_hash[:before] = params[:before]
      end

      relation.cursor_paginate(**params_hash)
    end

    def tag_base_scope
      Project
        .select(:id, :author_id, :image_preview, :name, :slug, :view, :description, :stars_count)
        .public_and_not_forked
        .joins(:tags)
        .where(tags: { id: @tag.id })
        .includes(:author, :stars)
        .with_attached_circuit_preview
    end
end
