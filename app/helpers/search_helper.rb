# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params)
    
    search_users = query_params[:search_users] == "1"
    search_projects = query_params[:search_projects] == "1"
 
    if !search_users && !search_projects
      search_users = true
      search_projects = true
    end
    
    if search_users && search_projects
     
      project_results = ProjectsQuery.new(query_params, Project.public_and_not_forked).results
      
    
      project_authors = project_results.includes(:author).map(&:author).uniq
    
      user_results = UsersQuery.new(query_params).results
      
   
      combined_users = (project_authors + user_results.to_a).uniq
      
  
      @users_with_projects = combined_users.map do |user|
        user_matching_projects = user.projects.public_and_not_forked
                                    .where("name ILIKE ? OR description ILIKE ?", 
                                           "%#{query_params[:q]}%", "%#{query_params[:q]}%")
                                    .limit(3) 
        {
          user: user,
          projects: user_matching_projects
        }
      end.select { |item| item[:projects].any? }
      
      return project_results, "/projects/search"
    elsif search_users
     
      return UsersQuery.new(query_params).results, "/users/circuitverse/search"
    elsif search_projects
    
      return ProjectsQuery.new(query_params, Project.public_and_not_forked).results, "/projects/search"
    end
    
    case resource
    when "Users"
      return UsersQuery.new(query_params).results, "/users/circuitverse/search"
    when "Projects"
      return ProjectsQuery.new(query_params, Project.public_and_not_forked).results, "/projects/search"
    end
  end
end