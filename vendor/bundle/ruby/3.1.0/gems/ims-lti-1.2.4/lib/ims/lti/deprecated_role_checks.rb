# These are here for backwards-compatibility
# But they are deprecated and the new ones in
# role_checks.rb should be used
module IMS::LTI
module DeprecatedRoleChecks
  # Check whether the Launch Parameters have a role
    def has_role?(role)
      role = role.downcase
      @roles && @roles.any?{|r| r.downcase.index(role)}
    end

    # Convenience method for checking if the user has 'learner' or 'student' role
    def student?
      has_role?('learner') || has_role?('student')
    end

    # Convenience method for checking if the user has 'instructor' or 'faculty' or 'staff' role
    def instructor?
      has_role?('instructor') || has_role?('faculty') || has_role?('staff')
    end

    # Convenience method for checking if the user has 'contentdeveloper' role
    def content_developer?
      has_role?('ContentDeveloper')
    end

    # Convenience method for checking if the user has 'Member' role
    def member?
      has_role?('Member')
    end

    # Convenience method for checking if the user has 'Manager' role
    def manager?
      has_role?('Manager')
    end

    # Convenience method for checking if the user has 'Mentor' role
    def mentor?
      has_role?('Mentor')
    end

    # Convenience method for checking if the user has 'administrator' role
    def admin?
      has_role?('administrator')
    end

    # Convenience method for checking if the user has 'TeachingAssistant' role
    def ta?
      has_role?('TeachingAssistant')
    end
end
end
