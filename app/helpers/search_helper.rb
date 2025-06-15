# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params)
    search_users = query_params[:search_users] == "1"
    search_projects = query_params[:search_projects] == "1"

    search_users = search_projects = true if !search_users && !search_projects

    return combined_search(query_params) if search_users && search_projects
    return users_only_search(query_params) if search_users
    return projects_only_search(query_params) if search_projects

    legacy_search(resource, query_params)
  end

  private

  def combined_search(query_params)
    project_results = ProjectsQuery.new(query_params, Project.public_and_not_forked).results
    user_results = UsersQuery.new(query_params).results

    projects_from_users = Project.public_and_not_forked
                                 .joins(:author)
                                 .where("users.name ILIKE ? OR users.email ILIKE ?",
                                        "%#{query_params[:q]}%", "%#{query_params[:q]}%")

    all_projects = (project_results.to_a + projects_from_users.to_a).uniq
    combined_users = (all_projects.map(&:author).uniq + user_results.to_a).uniq

    @users_with_projects = build_users_with_projects(combined_users, query_params)

    final_results = paginate_projects(all_projects, query_params)
    [final_results, "/projects/search"]
  end

  def build_users_with_projects(users, query_params)
    users.filter_map do |user|
      projects =
        if user_matches_query?(user, query_params[:q])
          user.projects.public_and_not_forked.limit(5)
        else
          user.projects.public_and_not_forked
               .where("name ILIKE ? OR description ILIKE ?",
                      "%#{query_params[:q]}%", "%#{query_params[:q]}%")
               .limit(3)
        end

      { user: user, projects: projects } if projects.any?
    end
  end

  def user_matches_query?(user, query)
    return false if query.blank?

    query_lower = query.to_s.downcase
    user.name.downcase.include?(query_lower) || user.email.downcase.include?(query_lower)
  end

  def paginate_projects(projects, query_params)
    Project.where(id: projects.map(&:id))
           .includes(:author, :tags, :stars)
           .order(created_at: :desc)
           .paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
  end

  def users_only_search(query_params)
    [UsersQuery.new(query_params).results, "/users/circuitverse/search"]
  end

  def projects_only_search(query_params)
    [ProjectsQuery.new(query_params, Project.public_and_not_forked).results, "/projects/search"]
  end

  def legacy_search(resource, query_params)
    case resource
    when "Users"
      users_only_search(query_params)
    when "Projects"
      projects_only_search(query_params)
    end
  end
end
