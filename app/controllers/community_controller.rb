# frozen_string_literal: true

class CommunityController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_period, only: [:leaderboard]

  # GET /community
  def index
    @stats = {
      total_users: User.count,
      total_projects: Project.count,
      total_contributions: calculate_total_contributions,
      active_users_last_month: User.where('last_sign_in_at > ?', 1.month.ago).count
    }

    @recent_projects = Project.includes(:author)
                              .order(updated_at: :desc)
                              .limit(6)
                              .select { |p| policy(p).show? }

    @top_contributors = get_top_contributors('all_time', 10)
  end

  # GET /community/leaderboard
  def leaderboard
    @time_period = params[:period] || 'weekly'
    @leaderboard_data = get_leaderboard_data(@time_period)
    @current_user_rank = get_user_rank(current_user, @time_period)
  end

  private

  def set_time_period
    @time_period = params[:period] || 'weekly'
    unless %w[weekly monthly yearly all_time].include?(@time_period)
      @time_period = 'weekly'
    end
  end

  def calculate_total_contributions
    # Calculate total contributions across all users
    total_pr_merged = PullRequest.where(state: 'merged').count
    total_pr_opened = PullRequest.count
    total_issues_opened = Issue.count
    
    (total_pr_merged * 5) + (total_pr_opened * 2) + (total_issues_opened * 1)
  end

  def get_top_contributors(period, limit = 10)
    case period
    when 'weekly'
      start_date = 1.week.ago
    when 'monthly'
      start_date = 1.month.ago
    when 'yearly'
      start_date = 1.year.ago
    else
      start_date = 100.years.ago # All time
    end

    User.joins("LEFT JOIN pull_requests ON pull_requests.author_id = users.id")
         .joins("LEFT JOIN issues ON issues.author_id = users.id")
         .where("pull_requests.created_at >= ? OR issues.created_at >= ? OR users.created_at >= ?", 
                start_date, start_date, start_date)
         .select(
           "users.*",
           "COALESCE(SUM(CASE WHEN pull_requests.state = 'merged' THEN 5 ELSE 0 END), 0) +
            COALESCE(SUM(CASE WHEN pull_requests.state != 'merged' THEN 2 ELSE 0 END), 0) +
            COALESCE(COUNT(DISTINCT issues.id) * 1, 0) as contribution_points",
           "COUNT(DISTINCT pull_requests.id) as pr_count",
           "COUNT(DISTINCT CASE WHEN pull_requests.state = 'merged' THEN pull_requests.id END) as merged_pr_count",
           "COUNT(DISTINCT issues.id) as issue_count"
         )
         .group("users.id")
         .order("contribution_points DESC, users.created_at ASC")
         .limit(limit)
  end

  def get_leaderboard_data(period)
    contributors = get_top_contributors(period, 100)
    
    contributors.map.with_index do |user, index|
      {
        rank: index + 1,
        user: user,
        contribution_points: user.contribution_points.to_i,
        pr_count: user.pr_count.to_i,
        merged_pr_count: user.merged_pr_count.to_i,
        issue_count: user.issue_count.to_i,
        breakdown: {
          merged_pr_points: user.merged_pr_count.to_i * 5,
          opened_pr_points: (user.pr_count.to_i - user.merged_pr_count.to_i) * 2,
          issue_points: user.issue_count.to_i * 1
        }
      }
    end
  end

  def get_user_rank(user, period)
    return nil unless user

    contributors = get_top_contributors(period, 1000)
    contributors.find_index { |contributor| contributor.id == user.id }&.+ 1
  end
end
