# frozen_string_literal: true

def create_live_contest(attrs = {})
  Contest.find_by(status: :live)&.update!(status: :completed)
  create(:contest, **{ deadline: 1.day.from_now, status: :live }.merge(attrs))
end
