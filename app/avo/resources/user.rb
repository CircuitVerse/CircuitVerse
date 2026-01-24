# frozen_string_literal: true

class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id
    field :email, as: :text
    field :sign_in_count, as: :number
    field :current_sign_in_at, as: :date_time
    field :last_sign_in_at, as: :date_time
    field :current_sign_in_ip, as: :text
    field :last_sign_in_ip, as: :text
    field :name, as: :text
    field :provider, as: :text
    field :uid, as: :text
    field :admin, as: :boolean
    field :country, as: :country
    field :educational_institute, as: :text
    field :subscribed, as: :boolean
    field :locale, as: :text
    field :confirmation_token, as: :text
    field :confirmed_at, as: :date_time
    field :confirmation_sent_at, as: :date_time
    field :unconfirmed_email, as: :text
    field :searchable, as: :text
    field :projects_count, as: :number
    field :profile_picture, as: :file
    field :forum_threads, as: :has_many
    field :forum_posts, as: :has_many
    field :forum_subscriptions, as: :has_many
    field :projects, as: :has_many
    field :stars, as: :has_many
    field :votes, as: :has_many
    field :rated_projects, as: :has_many, through: :stars
    field :groups_owned, as: :has_many
    field :group_members, as: :has_many
    field :groups, as: :has_many, through: :group_members
    field :grades, as: :has_many
    field :commontator_comments, as: :has_many
    field :commontator_subscriptions, as: :has_many
    field :submissions, as: :has_many
    field :collaborations, as: :has_many
    field :collaborated_projects, as: :has_many, through: :collaborations
    field :pending_invitations, as: :has_many
    field :noticed_notifications, as: :has_many
    field :push_subscriptions, as: :has_many
  end
  # rubocop:enable Metrics/MethodLength
end
