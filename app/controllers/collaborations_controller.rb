# frozen_string_literal: true

class CollaborationsController < ApplicationController
  before_action :set_collaboration, only: %i[update destroy]

  def self.policy_class
    ProjectPolicy
  end

  # POST /collaborations
  # POST /collaborations.json
  def create
    @project = Project.find(collaboration_params[:project_id])
    authorize @project, :author_access?

    results = process_collaboration_emails(collaboration_params[:emails])
    notice = build_collaboration_notice(results)

    respond_to do |format|
      format.html { redirect_to user_project_path(@project.author_id, @project.id), notice: notice }
    end
  end

  # PATCH/PUT /collaborations/1
  # PATCH/PUT /collaborations/1.json
  def update
    authorize @collaboration.project, :author_access?

    respond_to do |format|
      if @collaboration.update(collaboration_params)
        format.html do
          redirect_to @collaboration, notice: "Collaboration was successfully updated."
        end
        format.json { render :show, status: :ok, location: @collaboration }
      else
        format.html { render :edit }
        format.json { render json: @collaboration.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /collaborations/1
  # DELETE /collaborations/1.json
  def destroy
    authorize @collaboration.project, :author_access?

    @collaboration.destroy
    respond_to do |format|
      format.html do
        redirect_to user_project_path(@collaboration.project.author_id, @collaboration.project_id),
                    notice: "Collaboration was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_collaboration
      @collaboration = Collaboration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collaboration_params
      params.expect(collaboration: [:user_id, :project_id, { emails: [] }])
    end

    def process_collaboration_emails(input_emails)
      results = {
        added: 0,
        not_registered: [],
        invalid_emails: [],
        already_present: 0,
        self_invite: false
      }

      return results if input_emails.blank?

      already_collaborator_emails = User.where(id: @project.collaborations.pluck(:user_id))
                                        .pluck(:email).map(&:downcase)

      input_emails.each do |raw_email|
        email = raw_email.to_s.strip.downcase

        # Check for invalid email format
        unless email.match?(Devise.email_regexp)
          results[:invalid_emails] << raw_email if raw_email.present?
          next
        end

        # Check for self-invite (MUST NOT add to collaborators)
        if email == current_user.email.downcase
          results[:self_invite] = true
          next
        end

        # Check if already a collaborator
        if already_collaborator_emails.include?(email)
          results[:already_present] += 1
          next
        end

        # Look up user in database
        user = User.find_by(email: email)
        if user.nil?
          results[:not_registered] << email
        else
          Collaboration.where(project_id: @project.id, user_id: user.id).first_or_create
          results[:added] += 1
          already_collaborator_emails << email # Prevent duplicates in same batch
        end
      end

      results
    end

    def build_collaboration_notice(results)
      parts = []

      parts << "#{results[:added]} collaborator(s) added." if results[:added].positive?

      if results[:not_registered].any?
        results[:not_registered].each do |email|
          parts << "#{email}: not authorized with circuitverse."
        end
      end

      if results[:invalid_emails].any?
        results[:invalid_emails].each do |email|
          parts << "#{email}: invalid credentials."
        end
      end

      parts << "You can't add yourself." if results[:self_invite]

      parts << "#{results[:already_present]} user(s) already collaborator(s)." if results[:already_present].positive?

      parts.empty? ? "No changes made." : parts.join(" ")
    end
end
