class DeletedProject
  def name
    "Deleted Project"
  end

  def author
    DeletedUser.new
  end

  def id
    nil
  end
end
