# frozen_string_literal: true

class Api::V1::CommentSerializer
  include FastJsonapi::ObjectSerializer

  attribute :creator_name do |comment|
    comment.creator.name
  end

  attribute :upvotes, &:cached_votes_up
  attribute :downvotes, &:cached_votes_down

  # [ nil(unauthenticated), "unvoted", "upvoted", "downvoted" ]
  attribute :vote_status do |comment, params|
    if params[:current_user].nil?
      nil
    else
      current_user_vote = comment.get_vote_by(params[:current_user])
      if current_user_vote.nil?
        "unvoted"
      else
        current_user_vote.vote_flag ? "upvoted" : "downvoted"
      end
    end
  end

  attribute :is_deleted, &:is_deleted?
  attribute :has_edit_access do |comment, params|
    comment.can_be_edited_by?(params[:current_user])
  end
  attribute :has_delete_access do |comment, params|
    comment.can_be_deleted_by?(params[:current_user])
  end
  attributes :creator_type, :body, :created_at, :updated_at

  belongs_to :thread, serializer: Api::V1::DefaultSerializer
  belongs_to :editor, serializer: Api::V1::UserSerializer
  belongs_to :creator, serializer: Api::V1::UserSerializer
end
