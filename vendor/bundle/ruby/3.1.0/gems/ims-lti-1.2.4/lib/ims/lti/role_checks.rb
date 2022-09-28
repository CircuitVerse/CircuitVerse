module IMS::LTI
  # Some convenience methods for the most used roles
  # Take care when using context_ helpers, as the context of an LTI launch
  # determines the meaning of that role. For example, if the context is an
  # institution context instead of a course context, then the short role of
  # "Instructor" means they are a teacher at the institution, but not necessarily
  # of the course you're working in.
  #
  # Also note that these only check for the base roles. So, asking context_student?
  # only matches `urn:lti:role:ims/lis/Learner`, not `urn:lti:role:ims/lis/Learner/NonCreditLearner`
  # If you make use of the more specific roles you'll need to ask specifically for those:
  # @tool_provider.has_exact_role?("urn:lti:role:ims/lis/Learner/NonCreditLearner")
  # Or you can use `has_base_role?`
  module RoleChecks

    # Check whether the Launch Parameters have a given role
    def has_exact_role?(role)
      role = role.downcase
      @roles && @roles.any? { |r| r.downcase == role }
    end

    # Check whether the Launch Parameters have a given role ignoring
    # sub roles. So asking:
    # @tool_provider.has_base_role?("urn:lti:role:ims/lis/Instructor/")
    # will return true if the role is `urn:lti:role:ims/lis/Instructor/GuestInstructor`
    def has_base_role?(role)
      role = role.downcase
      @roles && @roles.any? { |r| r.downcase.start_with?(role) }
    end

    # Convenience method for checking if the user is the system administrator of the TC
    def system_administrator?
      has_exact_role?('urn:lti:sysrole:ims/lis/SysAdmin') ||
              has_exact_role?('SysAdmin') ||
              has_exact_role?('urn:lti:sysrole:ims/lis/Administrator')
    end

    ### Institution-level roles
    # Note, these only check if the role is explicitely an institution level role
    # if the context of the LTI launch is the institution, the short names
    # will apply, and you should use the context_x? helpers.

    # Convenience method for checking if the user has 'student' or 'learner' roles at the institution
    def institution_student?
      has_exact_role?('urn:lti:instrole:ims/lis/Student') || has_exact_role?('urn:lti:instrole:ims/lis/Learner')
    end

    # Convenience method for checking if the user has 'Instructor' role at the institution
    def institution_instructor?
      has_exact_role?('urn:lti:instrole:ims/lis/Instructor')
    end

    # Convenience method for checking if the user has 'Administrator' role at the institution
    def institution_admin?
      has_exact_role?('urn:lti:instrole:ims/lis/Administrator')
    end


    ### Context-level roles
    # Note, the most common LTI context is a course, but that is not always the
    # case. You should be aware of the context when using these helpers.
    # The difference for the context_ helpers is that they check for the
    # short version of the roles. So `Learner` and `urn:lti:role:ims/lis/Learner`
    # are both valid.

    # Convenience method for checking if the user has 'learner' role in the current launch context
    def context_student?
      has_exact_role?('Learner') || has_exact_role?('urn:lti:role:ims/lis/Learner')
    end

    # Convenience method for checking if the user has 'instructor' role in the current launch context
    def context_instructor?
      has_exact_role?('instructor') || has_exact_role?('urn:lti:role:ims/lis/Instructor')
    end

    # Convenience method for checking if the user has 'contentdeveloper' role in the current launch context
    def context_content_developer?
      has_exact_role?('ContentDeveloper') || has_exact_role?('urn:lti:role:ims/lis/ContentDeveloper')
    end

    # Convenience method for checking if the user has 'Mentor' role in the current launch context
    def context_mentor?
      has_exact_role?('Mentor') || has_exact_role?('urn:lti:role:ims/lis/Mentor')
    end

    # Convenience method for checking if the user has 'administrator' role in the current launch context
    def context_admin?
      has_exact_role?('Administrator') || has_exact_role?('urn:lti:role:ims/lis/Administrator')
    end

    # Convenience method for checking if the user has 'TeachingAssistant' role in the current launch context
    def context_ta?
      has_exact_role?('TeachingAssistant') || has_exact_role?('urn:lti:role:ims/lis/TeachingAssistant')
    end

    # Convenience method for checking if the user has 'Observer' role in the current launch context
    def context_observer?
      has_exact_role?('Observer') || has_exact_role?('urn:lti:instrole:ims/lis/Observer')
    end
  end
end
