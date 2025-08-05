# frozen_string_literal: true

module ContestsHelper
  def leaderboard_row_class(idx)
    %w[table-gold table-silver table-bronze][idx] || ""
  end

  def medal_for(idx)
    %w[🏆 🥈 🥉][idx] || (idx + 1)
  end
end
