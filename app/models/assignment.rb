class Assignment < ApplicationRecord

  belongs_to :group
  has_many :projects, class_name: 'Project', foreign_key: 'assignment_id', dependent: :nullify

  after_commit :send_new_assignment_mail, on: :create
  after_commit :set_deadline_job
  after_commit :send_update_mail, on: :update

  enum grading_scale: %i[no_scale letter percent]

  has_many :grades

  def send_new_assignment_mail
    self.group.group_members.each do |group_member|
      AssignmentMailer.new_assignment_email(group_member.user, self).deliver_later
    end

  end
  def send_update_mail

    if self.status != 'closed'
      self.group.group_members.each do |group_member|
        AssignmentMailer.update_assignment_email(group_member.user,self).deliver_later
      end
    end

  end
  def set_deadline_job
    if self.status != 'closed'
      if (self.deadline - Time.now>0)
        AssignmentDeadlineSubmissionJob.set(wait: ((self.deadline - Time.now)/60).minute).perform_later(self.id)
      else
       AssignmentDeadlineSubmissionJob.perform_later(self.id)
      end
    end
  end



end
