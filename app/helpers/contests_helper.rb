# frozen_string_literal: true

module ContestsHelper
  # Pastel row colour for podium places
  def leaderboard_row_class(idx)
    %w[table-gold table-silver table-bronze][idx] || ''
  end

  # Trophy / medal emoji for the top 3, otherwise the rank number
  def medal_for(idx)
    %w[🏆 🥈 🥉][idx] || (idx + 1)
  end
end
