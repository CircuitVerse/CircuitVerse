# frozen_string_literal: true

class Assignment < ApplicationRecord
  validates :name, length: { minimum: 1 }
  belongs_to :group
  has_many :projects, class_name: "Project", foreign_key: "assignment_id", dependent: :nullify

  after_commit :send_new_assignment_mail, on: :create
  after_commit :set_deadline_job
  after_commit :send_update_mail, on: :update

  enum grading_scale: { no_scale: 0, letter: 1, percent: 2, custom: 3 }

  has_many :grades, dependent: :destroy

  def send_new_assignment_mail
    group.group_members.each do |group_member|
      AssignmentMailer.new_assignment_email(group_member.user, self).deliver_later
    end
  end

  def send_update_mail
    if status != "closed"
      group.group_members.each do |group_member|
        AssignmentMailer.update_assignment_email(group_member.user, self).deliver_later
      end
    end
  end

  def set_deadline_job
    if status != "closed"
      if deadline - Time.zone.now > 0
        AssignmentDeadlineSubmissionJob.set(wait: ((deadline - Time.zone.now) / 60).minute).perform_later(id)
      else
        AssignmentDeadlineSubmissionJob.perform_later(id)
      end
    end
  end

  def graded?
    grading_scale != "no_scale"
  end

  def elements_restricted?
    restrictions != "[]"
  end

  def project_order
    projects.includes(:grade, :author).sort_by { |p| p.author.name }
            .map { |project| ProjectDecorator.new(project) }
  end
end
