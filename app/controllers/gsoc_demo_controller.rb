# frozen_string_literal: true

class GsocDemoController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    @root_groups = Group.where(parent_group_id: nil)
                        .includes(:primary_mentor, :child_groups,
                                  child_groups: [:child_groups, :primary_mentor])
                        .limit(10)
    @subgroups   = Subgroup.includes(:group, subgroup_members: :user).limit(8)
    @assignments = Assignment.includes(:group, :circuit_template,
                                       :assignment_submissions).limit(8)
    @submissions = AssignmentSubmission.includes(:user, :assignment).limit(6)
    @templates   = CircuitTemplate.includes(:created_by, :assignment_test_cases).limit(6)
    @test_cases  = AssignmentTestCase.includes(:assignment).limit(8)
    @lti_deployments = LtiDeployment.all
  end
end
