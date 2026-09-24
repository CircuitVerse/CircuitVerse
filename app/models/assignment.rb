# frozen_string_literal: true

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

  enum :grading_scale, { no_scale: 0, letter: 1, percent: 2, custom: 3 }
  default_scope { order(deadline: :asc) }
  has_many :grades, dependent: :destroy
  has_one :testbench, dependent: :destroy, autosave: true

  has_noticed_notifications model_name: "NoticedNotification", dependent: :destroy

  def notify_recipient
    group.group_members.each do |group_member|
      NewAssignmentNotification.with(assignment: self).deliver_later(group_member.user)
    end
  end

  def send_new_assignment_mail
    group.group_members.each do |group_member|
      AssignmentMailer.new_assignment_email(group_member.user, self).deliver_later
    end
  end

  def send_update_mail
    return unless status != "closed"

    group.group_members.each do |group_member|
      AssignmentMailer.update_assignment_email(group_member.user, self).deliver_later
    end
  end

  def set_deadline_job
    return unless status != "closed"

    if (deadline - Time.zone.now).positive?
      AssignmentDeadlineSubmissionJob.set(wait: ((deadline - Time.zone.now) / 60).minute).perform_later(id)
    else
      AssignmentDeadlineSubmissionJob.perform_later(id)
    end
  end

  def clean_restricted_elements
    restricted_elements = JSON.parse restrictions
    restricted_elements.map! { |element| ERB::Util.html_escape element }
    restricted_elements.to_json
  end

  def graded?
    grading_scale != "no_scale"
  end

  def elements_restricted?
    restrictions != "[]"
  end

  def lti_integrated?
    lti_consumer_key.present? && lti_shared_secret.present?
  end

  # Blank clears the suite; nil (field absent) leaves it untouched.
  def testbench_data=(json)
    return if json.nil?

    if !json.is_a?(String)
      invalidate_testbench_data!
    elsif json.blank?
      testbench&.mark_for_destruction
    else
      parsed = parse_testbench_suite(json)
      (testbench || build_testbench).data = parsed if parsed
    end
  end

  validate :testbench_data_parsed

  def testbench_data_parsed
    errors.add(:testbench, "must be valid JSON with a groups array") if @testbench_data_invalid
  end

  def project_order
    projects.includes(:grade, :author).sort_by { |p| p.author.name }
                                      .map { |project| ProjectDecorator.new(project) }
  end

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

  private

    def parse_testbench_suite(json)
      parsed = JSON.parse(json)
      groups = parsed["groups"] if parsed.is_a?(Hash)
      return parsed if groups.is_a?(Array) && valid_testbench_groups?(groups)

      invalidate_testbench_data!
      nil
    rescue JSON::ParserError
      invalidate_testbench_data!
      nil
    end

    def valid_testbench_groups?(groups)
      valid_pins = ->(pins) { pins.is_a?(Array) && pins.all? { |p| p.is_a?(Hash) && p["label"].is_a?(String) } }
      groups.all? { |g| g.is_a?(Hash) && valid_pins.call(g["inputs"]) && valid_pins.call(g["outputs"]) }
    end

    def invalidate_testbench_data!
      @testbench_data_invalid = true
    end
end
