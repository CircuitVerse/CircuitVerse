module ProjectsHelper
  def image_preview_url(project)
    if project.image_preview.attached?
      url_for(project.image_preview)
    else
      "/img/default.png"
    end
  end
end
