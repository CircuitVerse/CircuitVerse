# frozen_string_literal: true

#
# == Schema Information
#
# Table name: assignments
#
#  id            :bigint           not null, primary key
#  name          :string
#  deadline      :datetime
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :bigint
#  grading_scale :integer          default(0)
#  grades_finalized :boolean      default(FALSE)
#  status        :varchar          default("open")
#  restrictions :json             default("[]")
#  lti_consumer_key :string
#  lti_shared_secret :string
#  feature_restrictions :jsonb    default("{}")
#
# Indexes
#
#  index_assignments_on_group_id  (group_id)
#

class Assignment < ApplicationRecord
  validates :name, length: { minimum: 1 }, presence: true
  validates :grading_scale, inclusion: {
    in: %w[percent],
    message: "needs to be fixed at 1-100 for passing the grade back to LMS"
  }, if: :lti_integrated?
  belongs_to :group
  has_many :projects, class_name: "Project", dependent: :nullify

  after_commit :send_new_assignment_mail, on: :create
  after_commit :set_deadline_job
  after_commit :send_update_mail, on: :update
  after_create_commit :notify_recipient

  enum grading_scale: { no_scale: 0, letter: 1, percent: 2, custom: 3 }
  default_scope { order(deadline: :asc) }
  has_many :grades, dependent: :destroy

  has_noticed_notifications model_name: "NoticedNotification", dependent: :destroy

  # @return [void]
  def notify_recipient
    group.group_members.each do |group_member|
      NewAssignmentNotification.with(assignment: self).deliver_later(group_member.user)
    end
  end

  # @return [void]
  def send_new_assignment_mail
    group.group_members.each do |group_member|
      AssignmentMailer.new_assignment_email(group_member.user, self).deliver_later
    end
  end

  # @return [void]
  def send_update_mail
    if status != "closed"
      group.group_members.each do |group_member|
        AssignmentMailer.update_assignment_email(group_member.user, self).deliver_later
      end
    end
  end

  # @return [void]
  def set_deadline_job
    if status != "closed"
      if (deadline - Time.zone.now).positive?
        AssignmentDeadlineSubmissionJob.set(wait: ((deadline - Time.zone.now) / 60).minute).perform_later(id)
      else
        AssignmentDeadlineSubmissionJob.perform_later(id)
      end
    end
  end

  # @return [String] Return restricted elements in JSON String format
  def clean_restricted_elements
    restricted_elements = JSON.parse restrictions
    restricted_elements.map! { |element| ERB::Util.html_escape element }
    restricted_elements.to_json
  end

  # @return [Boolean] Return true if the assignment is graded
  def graded?
    grading_scale != "no_scale"
  end

  # @return [Boolean] Return true if the assignment has any element restriction
  def elements_restricted?
    restrictions != "[]"
  end

  # @return [Boolean] Return true if the assignment has LTI integration
  def lti_integrated?
    lti_consumer_key.present? && lti_shared_secret.present?
  end

  # Retrieves projects, eager loads associated grade and author records, sorts them by the name of the author
  # @return [Array<ProjectDecorator>] Return decorated project objects.
  def project_order
    projects.includes(:grade, :author).sort_by { |p| p.author.name }
            .map { |project| ProjectDecorator.new(project) }
  end

  # @return [void]
  def check_reopening_status
    projects.each do |proj|
      next unless proj.project_submission == true

      old_project = Project.find_by(id: proj.forked_project_id)
      if old_project.nil?
        proj.update(project_submission: false)
      else
        old_project.update(assignment_id: proj.assignment_id)
        proj.destroy
      end
    end
  end
end
