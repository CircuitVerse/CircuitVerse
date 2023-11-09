# frozen_string_literal: true

json.array! @projects, partial: "projects/project", as: :project
