# frozen_string_literal: true

class Api::V1::CommentSerializer
  include FastJsonapi::ObjectSerializer

  attribute :creator_name do |comment|
    comment.creator.name
  end

  attributes :creator_type, :body, :created_at, :updated_at, \
             :cached_votes_up, :cached_votes_down

  belongs_to :thread
  belongs_to :editor
  belongs_to :creator
end
