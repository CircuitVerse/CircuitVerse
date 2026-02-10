# frozen_string_literal: true

class ProjectFilters < Avo::Filters::BaseFilter
  self.name = "Project Filters"
  
  def apply(request, query)
    return query unless request.params.dig(:filters, :project_filters).present?

    filter_params = request.params.dig(:filters, :project_filters)
    
    query = query.where(name: filter_params[:name]) if filter_params[:name].present?
    query = query.joins(:author).where(users: { name: filter_params[:author] }) if filter_params[:author].present?
    query = query.where(created_at: filter_params[:created_at_from]..filter_params[:created_at_to]) if filter_params[:created_at_from].present? && filter_params[:created_at_to].present?
    
    query
  end

  def options
    {
      name: { 
        type: :text,
        placeholder: "Search by project name..."
      },
      author: {
        type: :select,
        options: User.all.map { |u| [u.name, u.id] },
        placeholder: "Filter by author..."
      },
      created_at_from: {
        type: :date,
        placeholder: "From date..."
      },
      created_at_to: {
        type: :date,
        placeholder: "To date..."
      }
    }
  end
end
