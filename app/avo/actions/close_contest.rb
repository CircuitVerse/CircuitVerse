# frozen_string_literal: true

class Avo::Actions::CloseContest < Avo::BaseAction
  self.name = "Close Contest & Select Winner"
  self.message = "Are you sure you want to close this contest and shortlist the winner? This cannot be undone."
  self.confirm_button_label = "Close Contest"
  self.cancel_button_label = "Cancel"

  self.visible = lambda {
    return true if view == :index
    return false if resource.nil? || resource.record.nil?

    resource.record.live?
  }
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def handle(query:, _fields:, current_user:, _resource:, **_args)
    unless current_user&.admin?
      error "Not authorized"
      return
    end

    unless Flipper.enabled?(:contests, current_user)
      error "Feature not available"
      return
    end

    closed_count = 0
    errors_list = []

    query.each do |contest|
      next unless contest.live?

      result = ShortlistContestWinner.new(contest.id).call

      if result[:success]
        if contest.update(deadline: Time.zone.now, status: :completed)
          closed_count += 1
        else
          errors_list << "Contest ##{contest.id}: #{contest.errors.full_messages.join(', ')}"
        end
      else
        errors_list << "Contest ##{contest.id}: #{result[:message]}"
      end
    end

    if closed_count.positive? && errors_list.empty?
      succeed "Successfully closed #{closed_count} contest(s) and shortlisted winner(s)!"
    elsif closed_count.positive? && errors_list.any?
      warn "Closed #{closed_count} contest(s) but had errors: #{errors_list.join('; ')}"
    else
      error "Failed to close contests: #{errors_list.join('; ')}"
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
end
