# frozen_string_literal: true

class Avo::Resources::Users < Avo::BaseResource
  self.title = :name
  self.includes = %i[projects groups_owned group_members]
  self.model_class = ::User
  self.search = {
    query: lambda {
      query.ransack(
        name_cont: params[:q],
        email_cont: params[:q],
        educational_institute_cont: params[:q],
        m: "or"
      ).result(distinct: false)
    }
  }

  def fields
    basic_fields
    authentication_fields
    tracking_fields
    profile_fields
    relationship_fields
  end

  private

    def basic_fields
      field :id, as: :id, link_to_resource: true
      field :name, as: :text, required: true, sortable: true
      field :email, as: :text, required: true, sortable: true
      field :admin, as: :boolean, sortable: true
      field :subscribed, as: :boolean, sortable: true
      field :country, as: :country
      field :educational_institute, as: :text
      field :locale, as: :text
    end

    def authentication_fields
      field :provider, as: :text
      field :uid, as: :text
    end

    def tracking_fields
      field :sign_in_count, as: :number, readonly: true
      field :current_sign_in_at, as: :date_time, readonly: true
      field :last_sign_in_at, as: :date_time, readonly: true
      field :current_sign_in_ip, as: :text, readonly: true
      field :last_sign_in_ip, as: :text, readonly: true

      field :confirmed_at, as: :date_time, readonly: true
      field :confirmation_sent_at, as: :date_time, readonly: true
      field :unconfirmed_email, as: :text, readonly: true
      field :confirmation_token, as: :text, readonly: true, hide_on: %i[index show]
    end

    def profile_fields
      field :projects_count, as: :number, readonly: true
      field :created_at, as: :date_time, readonly: true, sortable: true
      field :updated_at, as: :date_time, readonly: true
      field :profile_picture, as: :file, is_image: true
    end

    def relationship_fields
      field :projects, as: :has_many
      field :stars, as: :has_many
      field :votes, as: :has_many
      field :rated_projects, as: :has_many, through: :stars
      field :groups_owned, as: :has_many
      field :group_members, as: :has_many
      field :groups, as: :has_many, through: :group_members
      field :grades, as: :has_many
      field :submissions, as: :has_many
      field :collaborations, as: :has_many
      field :collaborated_projects, as: :has_many, through: :collaborations
      field :pending_invitations, as: :has_many
      field :noticed_notifications, as: :has_many
      field :push_subscriptions, as: :has_many
    end

  public

  def filters
    %i[
      Admin Subscribed Name Email EducationalInstitute Locale Provider Uid
      CurrentSignInIp LastSignInIp UnconfirmedEmail Id SignInCount ProjectsCount
      CurrentSignInAt LastSignInAt ConfirmedAt ConfirmationSentAt CreatedAt UpdatedAt
    ].each do |f|
      filter "Avo::Filters::Users::#{f}".constantize
    end
  end

  def actions
    action Avo::Actions::Users::ExportSelected
    action Avo::Actions::Users::DeleteSelected
  end
end
