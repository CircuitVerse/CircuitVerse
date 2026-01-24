# frozen_string_literal: true

class Avo::Actions::ExtendDeadline < Avo::BaseAction
  self.name = "Extend Deadline"
  self.message = "Set a new deadline for this contest"
  self.standalone = true

  self.visible = lambda {
    return true if view == :index
    return false if resource.nil? || resource.record.nil?

    resource.record.live?
  }

  def fields
    field :new_deadline, as: :date_time,
                         required: true,
                         help: "New deadline (must be in the future)"
  end

  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def handle(query:, fields:, current_user:, _resource:, **_args)
    unless current_user&.admin?
      error "Not authorized"
      return
    end

    unless Flipper.enabled?(:contests, current_user)
      error "Feature not available"
      return
    end

    new_deadline = fields[:new_deadline]

    if new_deadline.blank?
      error "Invalid deadline"
      return
    end

    if new_deadline <= Time.zone.now
      error "Deadline must be in the future"
      return
    end

    updated_count = 0
    errors_list = []

    query.each do |contest|
      next unless contest.live?

      if contest.update(deadline: new_deadline)
        ContestScheduler.call(contest)
        updated_count += 1
      else
        errors_list << "Contest ##{contest.id}: #{contest.errors.full_messages.join(', ')}"
      end
    end

    if updated_count.positive? && errors_list.empty?
      succeed "Successfully extended deadline for #{updated_count} contest(s)!"
    elsif updated_count.positive? && errors_list.any?
      warn "Extended #{updated_count} contest(s) but had errors: #{errors_list.join('; ')}"
    else
      error "Failed to extend deadlines: #{errors_list.join('; ')}"
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
end
