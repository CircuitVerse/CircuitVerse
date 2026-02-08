# frozen_string_literal: true

class Avo::Filters::BlobByContentType < Avo::Filters::SelectFilter
  self.name = "Content Type"

  def apply(_request, query, value)
    case value
    when "image"
      query.where("content_type LIKE ?", "image/%")
    when "pdf"
      query.where(content_type: "application/pdf")
    when "video"
      query.where("content_type LIKE ?", "video/%")
    when "text"
      query.where("content_type LIKE ?", "text/%")
    else
      query
    end
  end

  def options
    {
      "All" => nil,
      "Images" => "image",
      "PDFs" => "pdf",
      "Videos" => "video",
      "Text Files" => "text"
    }
  end
end
